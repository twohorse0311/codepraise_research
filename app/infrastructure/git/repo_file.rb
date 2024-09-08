# frozen_string_literal: true

module CodePraise
  module Git
    # Blame output for a single file
    class RepoFile
      attr_reader :filename

      def initialize(filename, target_path)
        @filename = filename
        @target_path = target_path
      end

      def blame
        @blame ||= CodePraise::Git::Command.new
          .blame(@filename, @target_path, porcelain: true)
          .call
      end
    end
  end
end
