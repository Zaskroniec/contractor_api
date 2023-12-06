# frozen_string_literal: true

require "test_helper"

module Contracts
  module Actions
    class UpdateTest < ActiveSupport::TestCase
      setup do
        @company = companies(:company)
        @contract = contracts(:with_guid)
        @service = Contracts::Actions::Update.new(contract_model: @contract)
      end

      test "updates contract for given params" do
        params = {
          start_at: "2023-12-13",
          end_at: "2023-12-29",
          wage_cents: 1_100,
          wage_currency: "USD",
          company_id: @company.id,
          company_signed_at: "2023-12-06 12:30:00",
          user_signed_at: "2023-12-06 12:30:00"
        }

        result = @service.call(params)

        assert result.start_at.to_s == "2023-12-13"
        assert result.end_at.to_s == "2023-12-29"
        assert result.wage_cents == 1_100
        assert result.wage_currency == "USD"
        assert result.company_id == @company.id
        assert result.company_signed_at.to_s == "2023-12-06 12:30:00 UTC"
        assert result.user_signed_at.to_s == "2023-12-06 12:30:00 UTC"
      end

      test "returns validation errors when contract is already signed by user" do
        @contract.update!({user_signed_at: DateTime.now})

        params = {user_signed_at: "2024-01-01 12:00:00"}

        result = @service.call(params)

        assert result[:user_signed_at] == ["already signed by user"]
      end

      test "returns validation errors when company signature is given without assigned company" do
        params = {company_signed_at: "2024-01-01 12:00:00"}

        result = @service.call(params)

        assert result[:company_signed_at] == ["cannot sign without valid company_id"]
      end

      test "returns validation errors when contract is already signed by company" do
        @contract.update!({company_id: @company.id, company_signed_at: DateTime.now})
        params = {company_signed_at: "2024-01-01 12:00:00"}

        result = @service.call(params)

        assert result[:company_signed_at] == ["already signed by company"]
      end

      test "returns validation errors when reassign company" do
        @contract.update!({company_id: @company.id, company_signed_at: DateTime.now})
        params = {company_id: 2}

        result = @service.call(params)

        assert result[:company_id] == ["cannot reassign company_id"]
      end

      test "returns validation error with incorrect state of dates when signatures of user and company are not provided" do
        @contract.update!({company_id: @company.id})

        params = {
          start_at: "2024-01-01",
          end_at: "2023-12-31"
        }

        result = @service.call(params)

        assert result[:start_at] == ["cannot change contract dates without user and company signatures"]
      end

      test "returns validation error with incorrect date range" do
        @contract.update!({company_id: @company.id, company_signed_at: DateTime.now, user_signed_at: DateTime.now})

        params = {
          start_at: "2024-01-01",
          end_at: "2023-12-31"
        }

        result = @service.call(params)

        assert result[:start_at] == ["start_at cannot be after end_at"]
      end

      test "returns validation error with already taken date range for given user when start_at overlaps on existed contract end_at" do
        _second_contract = contracts(:signed)
        @contract.update!({company_id: @company.id, company_signed_at: DateTime.now, user_signed_at: DateTime.now})

        params = {
          start_at: "2024-01-01",
          end_at: "2024-06-30"
        }

        result = @service.call(params)

        assert result[:start_at] == ["user already have contract within the given date range"]
      end
    end
  end
end
