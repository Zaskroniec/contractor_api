# frozen_string_literal: true

require "test_helper"

module Api
  class ContractsControllerTest < ::ActionDispatch::IntegrationTest
    test "returns contract for GET show" do
      contract = contracts(:signed)

      get contract_path(contract)

      assert_equal 200, status
    end

    test "returns not_found response for GET show" do
      get contract_path(999)

      assert_equal 404, status
    end

    test "returns contract for POST create" do
      user = users(:user)
      params = {
        start_at: "2024-01-01",
        end_at: "2024-01-11",
        user_id: user.id,
        wage_cents: 1399,
        wage_currency: "USD"
      }

      assert_difference -> { Contract.count }, 1 do
        post contracts_path, params: {contract: params}

        assert_response :success

        response = JSON.parse(@response.body, symbolize_names: true)
        response_keys = response[:data].keys
        expected_keys = %i[contract_number average_weekly_hours
          hourly_wage created_at updated_at user_id]

        assert expected_keys.all? { |key| response_keys.include?(key) }
      end
    end

    test "returns not_found for POST create" do
      post contracts_path, params: {contract: {user_id: 999}}

      assert_equal 404, status
    end

    test "returns unprocessably_entity for POST create" do
      post contracts_path, params: {contract: {}}

      assert_equal 422, status
    end

    test "returns contract for PATCH update" do
      contract = contracts(:signed)

      params = {
        start_at: "2024-01-01",
        end_at: "2024-01-11",
        wage_cents: 1399,
        wage_currency: "USD"
      }

      patch contract_path(contract), params: {contract: params}

      assert_equal 200, status

      response = JSON.parse(@response.body, symbolize_names: true)
      response_keys = response[:data].keys
      expected_keys = %i[contract_number average_weekly_hours
        hourly_wage created_at updated_at user_id]

      assert expected_keys.all? { |key| response_keys.include?(key) }
    end

    test "returns not_found for PATCH update for given company" do
      contract = contracts(:signed)

      patch contract_path(contract), params: {contract: {company_id: 999}}

      assert_equal 404, status
    end

    test "returns unprocessably_entity for PATCH update" do
      contract = contracts(:signed)

      patch contract_path(contract), params: {contract: {wage_cents: -100}}

      assert_equal 422, status
    end

    test "returns no_content for DELETE destroy" do
      contract = contracts(:signed)

      assert_difference -> { Contract.count }, -1 do
        delete contract_path(contract)
      end

      assert_equal 204, status
    end

    test "returns not_found for DELETE destroy" do
      delete contract_path(999)

      assert_equal 404, status
    end

    test "returns ok for POST archive" do
      post archive_contracts_path, params: {import: fixture_file_upload("test.csv", "text/csv")}

      assert_equal 200, status

      response = JSON.parse(@response.body, symbolize_names: true)
      filename = response[:status_file].split("/").last
      status_file_path = Rails.root.join("public", filename)

      File.delete(status_file_path)
    end

    test "returns unprocessably_entity for POST archive" do
      post archive_contracts_path, params: {import: {}}

      assert_equal 422, status
    end
  end
end
