# frozen_string_literal: true

require_relative '../init.rb'

module Appraisal
  # Using the class to manage the cache state and change the state
  class CacheState
    BACK = {
      'cloning'    => 'init',
      'appraising' => 'cloned'
    }.freeze

    def initialize(cache)
      @cache = cache
    end

    def cloning?
      %w[cloning cloned appraising appraised stored].include?(@cache.state)
    end

    def cloned?
      %w[cloned appraising appraised stored].include?(@cache.state)
    end

    def appraising?
      %w[appraising appraised stored].include?(@cache.state)
    end

    def appraised?
      %w[appraised stored].include?(@cache.state)
    end

    def stored?
      @cache.state == 'stored'
    end

    def back(gitrepo)
      if gitrepo.exists_locally?
        update_state('cloned')
      else
        update_state('init')
      end
    end

    def update_state(state)
      data = { state: state }
      @cache = CodePraise::Repository::Appraisal
        .update(id: @cache.id, data: data)
    end
  end
end
