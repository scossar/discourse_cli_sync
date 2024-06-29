# frozen_string_literal: true

require_relative '../../utils/api_credentials'
require_relative '../../utils/api_key'
require_relative '../../utils/ask_password'
require_relative '../../utils/discourse_config'
require_relative '../../utils/category_info'
require_relative '../../utils/note_selector'
require_relative '../../utils/category_selector'
require_relative '../../utils/ui_utils'

module Discourse
  module Commands
    class PublishNotes < Discourse::Command
      def call(_args, _name)
        host, _password, api_key = credential_frames
        categories, _category_names = site_info_frame(host, api_key)
        notes, dir = note_selector_frame(host)
        category_id = category_selector_frame(notes, categories)
        publish_notes_frame(host:, notes:, dir:, category_id:, api_key:)
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
          categories, category_names = Discourse::Utils::CategoryInfo.category_loader(host, api_key)
          [categories, category_names]
        end
      end

      def note_selector_frame(host)
        CLI::UI::Frame.open('Select note') do
          Discourse::Utils::NoteSelector.call(host)
        end
      end

      def category_selector_frame(notes, categories)
        notes_str = Discourse::Utils::Ui.colored_text_from_array(notes, 'green')
        CLI::UI::Frame.open("Category for #{notes_str}") do
          Discourse::Utils::CategorySelector.call(categories, notes)
        end
      end

      def publish_notes_frame(host:, notes:, dir:, category_id:, api_key:)
        notes_str = Discourse::Utils::Ui.colored_text_from_array(notes, 'green')
        CLI::UI::Frame.open("Publishing #{notes_str}") do
          puts "host: #{host}, notes: #{notes}, dir: #{dir}, category_id: #{category_id}, api_key: #{api_key}"
        end
      end
    end
  end
end
