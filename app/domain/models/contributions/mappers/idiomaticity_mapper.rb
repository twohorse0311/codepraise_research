# frozen_string_literal: true

module CodePraise
  module Mapper
    # Parse the code style offense and calcualte the offense ratio for the file
    class Idiomaticity
      def initialize(git_repo_path)
        @git_repo_path = git_repo_path
        @rubocop_reporter = CodePraise::Rubocop::Reporter.new(git_repo_path)
      end

      def build_entity(file_path, file_contributions)
        offenses = offenses(file_path, file_contributions)

        cyclomatic_complexity = offenses.select { |offense| offense.type == 'Metrics/CyclomaticComplexity' }
                                        .map { |entity| entity.message.match(/\[(\d+)\//)&.captures&.first.to_i || 0 }
                                        .reduce(0, :+)
        offenses = offenses.reject { |offense| offense.type.include? 'Metrics/' }

        Entity::Idiomaticity.new(
          offenses: offenses,
          offense_ratio: offense_ratio(offenses, file_contributions),
          cyclomatic_complexity: cyclomatic_complexity
        )
      end

      private

      def offenses(file_path, file_contributions)
        idiomaticity_result = @rubocop_reporter.report["#{@git_repo_path}/#{file_path}"]

        return [] if idiomaticity_result.nil?

        idiomaticity_result.map do |offense_hash|
          Entity::RubocopOffense.new(
            type: offense_hash['cop_name'],
            message: offense_hash['message'],
            location: offense_hash['location'].slice('start_line', 'last_line'),
            line_count: line_count(offense_hash['location']),
            contributors: contributors(offense_hash, file_contributions)
          )
        end
      end

      def contributors(offense_hash, file_contributions)
        first_line = offense_hash['location']['start_line'] - 1
        last_line = offense_hash['location']['last_line'] - 1
        file_contributions[first_line..last_line]
          .each_with_object(Hash.new(0)) do |line_contribution, hash|
            hash[line_contribution.contributor.email_id] += 1
          end
      end

      def line_count(location)
        location['last_line'] - location['start_line'] + 1
      end

      def offense_ratio(offenses, file_contributions)
        return 0.0 if offenses.empty? || file_contributions.empty?

        (offenses.map(&:line_count).reduce(&:+).to_f / file_contributions.size)
          .round(2)
      end
    end
  end
end
