module Api
  class ContractsController < ApplicationController
    def show
      contract
    end

    # result.is_a? may look quite strange here. Overall i thought about using some kind of Monads logic from dry-system,
    # but in the end i have approach with simple result from the service object. I didn't want to raise exception with validation errors
    # to avoid time excecution for serialization and deserialization json with errors. Alternative would be to return [:ok/:error, object]
    # and then return response, but it is not very common approach with Ruby (probably noone done that :D).
    def create
      @user = maybe_fetch_user!
      result = Contracts::Actions::Create.new.call(contract_params)

      if result.is_a?(Contract)
        @contract = result

        render :show, status: :created
      else
        render json: {errors: result, code: 422}, status: :unprocessable_entity
      end
    end

    def update
      @company = maybe_fetch_company!
      result = Contracts::Actions::Update.new(contract_model: contract).call(contract_params)

      if result.is_a?(Contract)
        @contract = result

        render :show, status: :ok
      else
        render json: {errors: result, code: 422}, status: :unprocessable_entity
      end
    end

    def destroy
      contract.destroy!

      head :no_content
    end

    def archive
      result = Contracts::Actions::Archive.new.call(unsafe_params[:import])
      port = ENV.fetch("PORT") { 3000 }
      download_path = "http://localhost:#{port}/#{result}"

      render json: {status_file: download_path}, status: :ok
    rescue Contracts::Actions::Archive::InvalidImportFile => e
      render json: {code: 422, message: e.message}, status: :unprocessable_entity
    end

    private

    def contract_params
      unsafe_params[:contract] || {}
    end

    def contract
      @contract ||= Contract.find(unsafe_params[:id])
    end

    def maybe_fetch_user!
      if contract_params[:user_id]
        User.find(contract_params[:user_id])
      end
    end

    def maybe_fetch_company!
      if contract_params[:company_id]
        Company.find(contract_params[:company_id])
      end
    end
  end
end
