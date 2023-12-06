# frozen_string_literal: true

module Contracts
  module Validators
    class Create < Dry::Validation::Contract
      option :query

      params do
        required(:start_at).value(:date)
        required(:end_at).value(:date)
        required(:wage_cents).value(:integer, gteq?: 0, lteq?: 1_000_000_000)
        required(:wage_currency).value(:string, included_in?: %w[EUR USD])
        required(:user_id).value(:integer)
        optional(:average_weekly_hours).value(:float)
      end

      rule(:start_at, :end_at) do
        if values[:start_at].after?(values[:end_at])
          key(:start_at).failure("start_at cannot be after end_at")
        end
      end

      rule(:user_id, :start_at, :end_at) do
        if query.uniq_date_range?(values[:user_id], values[:start_at], values[:end_at])
          key(:start_at).failure("user already have contract within the given date range")
        end
      end
    end
  end
end
