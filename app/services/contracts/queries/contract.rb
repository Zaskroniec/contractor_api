# frozen_string_literal: true

module Contracts
  module Queries
    class Contract
      def initialize(repository: ::Contract)
        @repository = repository
      end

      def uniq_date_range?(user_id, start_at, end_at)
        repository
          .then { |query| filter_by_user_id(query, user_id) }
          .then { |query| filter_by_overlaps(query, start_at, end_at) }
          .exists?
      end

      def uniq_date_range_without_id?(id, user_id, start_at, end_at)
        repository
          .then { |query| filter_by_user_id(query, user_id) }
          .then { |query| filter_without_id(query, id) }
          .then { |query| filter_by_overlaps(query, start_at, end_at) }
          .exists?
      end

      def list_by_guids(guids)
        repository
          .where(["guid in (?)", guids])
          .all
      end

      private

      def filter_by_user_id(query, user_id)
        query.where(["user_id = ?", user_id])
      end

      def filter_by_overlaps(query, start_at, end_at)
        query.where([
          "(start_at, end_at) OVERLAPS (?, ?) OR start_at = ? OR end_at = ?",
          start_at, end_at, end_at, start_at
        ])
      end

      def filter_without_id(query, id)
        query.where.not(id: id)
      end

      attr_reader :repository
    end
  end
end
