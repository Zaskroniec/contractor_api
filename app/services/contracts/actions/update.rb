# frozen_string_literal: true

module Contracts
  module Actions
    class Update
      def initialize(
        contract_model:,
        repository: Contract,
        validator: Contracts::Validators::Update.new(
          contract_model: contract_model,
          query: Contracts::Queries::Contract.new(repository: repository)
        )
      )
        @contract_model = contract_model
        @user_model = user_model
        @repository = repository
        @validator = validator
      end

      def call(params)
        validation = validator.call(params)

        return validation.errors.to_h if validation.failure?

        contract_model.update(validation.to_h)

        contract_model
      end

      private

      attr_reader :contract_model, :user_model, :repository, :validator
    end
  end
end
