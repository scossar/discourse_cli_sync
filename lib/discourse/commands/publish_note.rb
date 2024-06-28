# frozen_string_literal: true

require_relative '../../utils/api_credentials'
require_relative '../../utils/api_key'
require_relative '../../utils/ask_password'
require_relative '../../utils/discourse_config'
require_relative '../../ui/category_info'

module Discourse
  module Commands
    class PublishNote < Discourse::Command
      def call(_args, _name)
        host, _password, api_key = credential_frames
        _categories, _category_names = site_info_frame(host, api_key)
      end

      def self.help
        'Publishes a markdown file to Discourse'
      end

      def credential_frames
        CLI::UI::Frame.open('Discourse credentials') do
          host = Discourse::Utils::DiscourseConfig.call
          password = Discourse::Utils::ApiCredentials.call(host)
          password ||= Discourse::Utils::AskPassword.ask_password('Your API key password')
          api_key = Discourse::Utils::ApiKey.api_key(host, password)
          [host, password, api_key]
        end
      end

      def site_info_frame(host, api_key)
        CLI::UI::Frame.open('Discourse info') do
          categories, category_names = Discourse::UI.category_loader(host, api_key)
          [categories, category_names]
        end
      end
    end
  end
end
