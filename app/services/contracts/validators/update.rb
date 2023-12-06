# frozen_string_literal: true

module Contracts
  module Validators
    class Update < Dry::Validation::Contract
      option :query
      option :contract_model

      params do
        optional(:start_at).value(:date)
        optional(:end_at).value(:date)
        optional(:wage_cents).value(:integer, gteq?: 0, lteq?: 1_000_000_000)
        optional(:wage_currency).value(:string, included_in?: %w[EUR USD])
        optional(:company_signed_at).value(:date_time)
        optional(:user_signed_at).value(:date_time)
        optional(:company_id).value(:integer)
        optional(:average_weekly_hours).value(:float)
      end

      rule(:user_signed_at) do
        if contract_model.user_signed_at.present? && key?
          key(:user_signed_at).failure("already signed by user")
        end
      end

      rule(:company_signed_at) do
        if key? && contract_model.company_id.blank? && !key?(:company_id)
          key(:company_signed_at).failure("cannot sign without valid company_id")
        elsif contract_model.company_signed_at.present? && key?
          key(:company_signed_at).failure("already signed by company")
        end
      end

      rule(:company_id) do
        if contract_model.company_id.present? && key?(:company_id)
          key(:company_id).failure("cannot reassign company_id")
        end
      end

      rule(:start_at, :end_at) do
        if date_range_values?(values) && contract_not_signed?(values, contract_model)
          key(:start_at).failure("cannot change contract dates without user and company signatures")
        elsif key?(:start_at) && key?(:end_at) && values[:start_at].after?(values[:end_at])
          key(:start_at).failure("start_at cannot be after end_at")
        elsif key?(:start_at) && !key?(:end_at) && values[:start_at].after?(contract_model.end_at)
          key(:start_at).failure("start_at cannot be after end_at")
        elsif !key?(:start_at) && key?(:end_at) && contract_model.start_at.after?(values[:end_at])
          key(:end_at).failure("start_at cannot be after end_at")
        elsif date_range_values?(values) && exists_similar_contract?(contract_model, values)
          key(:start_at).failure("user already have contract within the given date range")
        end
      end

      private

      def date_range_values?(values)
        values[:start_at].present? || values[:end_at].present?
      end

      def contract_not_signed?(values, contract_model)
        contract_model.user_signed_at.blank? && values[:user_signed_at].blank? &&
          contract_model.company_signed_at.blank? && values[:company_signed_at].blank?
      end

      def exists_similar_contract?(contract_model, values)
        query.uniq_date_range_without_id?(
          contract_model.id,
          contract_model.user_id,
          values[:start_at] || contract_model.start_at,
          values[:end_at] || contract_model.end_at
        )
      end
    end
  end
end
