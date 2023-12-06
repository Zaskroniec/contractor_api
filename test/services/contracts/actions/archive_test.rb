# frozen_string_literal: true

require "test_helper"

module Contracts
  module Actions
    class ArchiveTest < ActiveSupport::TestCase
      setup do
        @path = Rails.root.join("tmp", "storage")
        @service = Contracts::Actions::Archive.new(path: @path)
      end

      test "returns status file with success result" do
        c1 = contracts(:with_guid)
        c2 = contracts(:signed)

        file = load_test_file("test.csv")
        result = @service.call(file[:upload])
        status_path = @path.join(result)

        data = File.read(status_path)

        assert data =~ /N00002,Processed successfuly/
        assert data =~ /N00003,Processed successfuly/

        assert c1.reload.archive_number == "xyz1"
        assert c2.reload.archive_number == "xyz2"

        File.delete(status_path)
        file[:tempfile].close
        file[:tempfile].unlink
      end

      test "raises exception when given invalid file" do
        assert_raise Contracts::Actions::Archive::InvalidImportFile, "Invalid import file" do
          @service.call({})
        end
      end

      test "returns status file with failure status" do
        c1 = contracts(:with_guid)
        c2 = contracts(:signed)

        c1.update!({archive_number: "xyz1"})

        file = load_test_file("test_failure.csv")
        result = @service.call(file[:upload])
        status_path = @path.join(result)

        data = File.read(status_path)

        assert data =~ /N00002,Contract already archived/
        assert data =~ /N00003,Archive number already exists/
        assert data =~ /N00099,Contract not found/

        assert c1.reload.archive_number == "xyz1"
        assert c2.reload.archive_number.nil?
        assert Contract.find_by(guid: "N00099").nil?

        File.delete(status_path)
        file[:tempfile].close
        file[:tempfile].unlink
      end
    end
  end
end
