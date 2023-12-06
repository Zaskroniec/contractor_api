# frozen_string_literal: true

require "test_helper"

module Contracts
  module Actions
    class CreateTest < ::ActiveSupport::TestCase
      setup do
        @service = Contracts::Actions::Create.new
      end

      test "creates contract for given params" do
        user = users(:user)

        params = {
          start_at: "2023-11-01",
          end_at: "2023-11-11",
          wage_cents: 1_000,
          wage_currency: "EUR",
          user_id: user.id
        }

        assert_difference -> { Contract.count }, 1 do
          result = @service.call(params)

          assert result.start_at.to_s == "2023-11-01"
          assert result.end_at.to_s == "2023-11-11"
          assert result.wage_cents == 1_000
          assert result.wage_currency == "EUR"
          assert result.user_id == user.id
        end
      end

      test "returns validation errors for empty params" do
        params = {}
        result = @service.call(params)

        assert result == {
          start_at: ["is missing"],
          end_at: ["is missing"],
          wage_cents: ["is missing"],
          wage_currency: ["is missing"],
          user_id: ["is missing"]
        }
      end

      test "returns validation error with incorrect wage_cents" do
        params = {wage_cents: -10}
        result = @service.call(params)

        assert result[:wage_cents] == ["must be greater than or equal to 0"]

        params = {wage_cents: 1_000_000_001}
        result = @service.call(params)

        assert result[:wage_cents] == ["must be less than or equal to 1000000000"]
      end

      test "returns validation error with incorrect wage_currency" do
        params = {wage_currency: "PLN"}
        result = @service.call(params)

        assert result[:wage_currency] == ["must be one of: EUR, USD"]
      end

      test "returns validation error with incorrect date range" do
        params = {
          start_at: "2023-12-12",
          end_at: "2023-12-11"
        }

        result = @service.call(params)

        assert result[:start_at] == ["start_at cannot be after end_at"]
      end

      test "returns validation error with already taken date range for given user when dates overlap" do
        second_contract = contracts(:with_guid)

        params = {
          start_at: "2023-12-13",
          end_at: "2023-12-31",
          wage_cents: 1_000,
          wage_currency: "EUR",
          user_id: second_contract.user_id
        }

        result = @service.call(params)

        assert result[:start_at] == ["user already have contract within the given date range"]
      end

      test "returns validation error with already taken date range for given user when end_date overlaps on existed contract start_at" do
        second_contract = contracts(:with_guid)

        params = {
          start_at: "2023-12-11",
          end_at: "2023-12-12",
          wage_cents: 1_000,
          wage_currency: "EUR",
          user_id: second_contract.user_id
        }

        result = @service.call(params)

        assert result[:start_at] == ["user already have contract within the given date range"]
      end

      test "returns validation error with already taken date range for given user when start_at overlaps on existed contract end_at" do
        second_contract = contracts(:with_guid)

        params = {
          start_at: "2023-12-31",
          end_at: "2024-01-30",
          wage_cents: 1_000,
          wage_currency: "EUR",
          user_id: second_contract.user_id
        }

        result = @service.call(params)

        assert result[:start_at] == ["user already have contract within the given date range"]
      end
    end
  end
end
