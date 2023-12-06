ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def load_test_file(csv_destination_name)
      data = File.read(Rails.root.join("test", "fixtures", "files", csv_destination_name))
      tempfile = Tempfile.new([SecureRandom.uuid, ".csv"])
      tempfile.write(data)
      tempfile.rewind

      upload = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: File.basename(tempfile),
        type: "text/csv"
      )

      {upload: upload, tempfile: tempfile}
    end
  end
end
