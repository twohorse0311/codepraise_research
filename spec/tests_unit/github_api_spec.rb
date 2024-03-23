# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe CodePraise::Github::Api do
  before do
    token = CodePraise::Api.config.GITHUB_TOKEN
    @github_api = CodePraise::Github::Api.new(token)
    result = @github_api.contributors_data('https://api.github.com/repos/soumyaray/YPBT-app/contributors')
  end

end
