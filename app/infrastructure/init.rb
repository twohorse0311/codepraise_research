# frozen_string_literal: true

folders = %w[github database git cache messaging flog rubocop reek simplecov]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
