# frozen_string_literal: true

module Contracts
  module Actions
    class Create
      def initialize(
        repository: Contract,
        validator: Contracts::Validators::Create.new(
          query: Contracts::Queries::Contract.new(repository: repository)
        )
      )
        @repository = repository
        @validator = validator
      end

      def call(params)
        validation = validator.call(params)

        return validation.errors.to_h if validation.failure?

        repository.transaction do
          repository
            .create(validation.to_h)
            .then { |contract| contract.generate_guid }
        end
      end

      private

      attr_reader :repository, :validator
    end
  end
end
