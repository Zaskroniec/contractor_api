require "csv"

module Contracts
  module Actions
    class Archive
      class InvalidImportFile < StandardError; end

      BATCH_SIZE = 200
      CSV_HEADERS = %i[contract_number status]

      def initialize(
        path: Rails.root.join("public"),
        query: Contracts::Queries::Contract.new(repository: Contract)
      )
        @path = path
        @file_status_name = "#{SecureRandom.uuid}.csv"
        @file_status = CSV.open(path.join(@file_status_name), "a", col_sep: ",", headers: CSV_HEADERS)
        @query = query
      end

      # The way I have implemented this feature is very optimistic and should be taken
      # as an simple example of processing csv on the fly. In real case scenarion I would not
      # implement this process within the request lifetime, but i would rather schedule backgroud task.
      # So for the solution I have schoosed very simple approach with processing file during the request lifetime.
      #
      # Solution A: task that process csv, brodcast result to the client to fetch result on different endpoint based on the import UUID
      # Soltuin B: task that process csv, check on different endpoint the progress of the import based on the unique UUID
      #
      # Current solution won't load whole CSV into memory, but if the file is too big then client will receive timeout
      def call(file)
        tempfile = get_temp_file(file)

        CSV.foreach(tempfile.path, headers: true).each_slice(BATCH_SIZE).each do |batch|
          guids = batch.map { |row| row["contract_number"] }
          contracts = query.list_by_guids(guids)
          batch_state = batch.each_with_object({}) do |item, memo|
            memo[item["contract_number"]] = {
              "row" => item,
              "contract" => contracts.find { |model| model.guid == item["contract_number"] }
            }
          end

          batch.each do |row|
            dataset = batch_state[row["contract_number"]]

            process_row(dataset)
          end

          file_status.flush
        end

        file_status.close
        file_status_name
      end

      private

      def get_temp_file(file)
        unless file.respond_to?(:tempfile)
          File.delete(path.join(file_status_name))

          raise InvalidImportFile, "Invalid import file"
        end

        file.tempfile
      end

      def process_row(dataset)
        contract = dataset["contract"]

        return append_row_status(dataset, "Contract not found") if contract.blank?
        return append_row_status(dataset, "Contract already archived") if contract.archive_number.present?

        contract.update({archive_number: dataset["row"]["archive_number"]})
        append_row_status(dataset, "Processed successfuly")
      rescue ActiveRecord::RecordNotUnique => _e
        append_row_status(dataset, "Archive number already exists")
      end

      def append_row_status(mapping, reason)
        file_status << {contract_number: mapping["row"]["contract_number"], status: reason}
      end

      attr_reader :path, :file_status, :file_status_name, :query
    end
  end
end
