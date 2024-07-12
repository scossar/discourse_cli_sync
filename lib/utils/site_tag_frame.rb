# frozen_string_literal: true

# TODO: probably don't need notes here
require_relative '../models/note'
require_relative '../models/discourse_topic'
require_relative 'update_tags_frame'

module Discourse
  module Utils
    class SiteTagFrame
      class << self
        def call(discourse_site:, api_key:)
          @discourse_site = discourse_site
          @initial_site_tag = @discourse_site&.site_tag
          @api_key = api_key
          @tag_regex = /^[\w-]{3,20}$/
          tag_frame
        end

        private

        def tag_frame
          CLI::UI::Frame.open("Site tag for {{blue:#{@discourse_site.domain}}}") do
            if @initial_site_tag
              confirm_site_tag(@initial_site_tag)
            else
              set_site_tag
            end
          end
        end

        def confirm_site_tag(site_tag)
          keep_site_tag = CLI::UI::Prompt
                          .confirm("All notes published to {{blue:#{@discourse_site.domain}}} " \
                                   "will be tagged with {{bold:#{site_tag}}}. Keep configuration?")
          return if keep_site_tag

          confirm = CLI::UI::Prompt
                    .confirm('Confirm that you want to change or remove the tag used for ' \
                             "{{blue:#{@discourse_site.domain}}}.")
          return unless confirm

          set_site_tag

          update_topic_tags
        end

        def set_site_tag
          tag = nil
          loop do
            tag = CLI::UI::Prompt
                  .ask("Tag for notes published from #{@discourse_site.domain}. " \
                       '(Leave empty to publish notes without tags.)')
            valid_tag = @tag_regex.match(tag) || tag.empty?
            unless valid_tag
              tag = CLI::UI::Prompt
                    .ask("{{bold:#{tag}}} is not valid. Please try again")
            end

            confirm = CLI::UI::Prompt.confirm(tag_confirm_prompt(tag))
            break if confirm
          end
          site_tag = tag.empty? ? nil : tag
          update_site_tag(site_tag)
        end

        def update_site_tag(site_tag)
          @discourse_site.update(site_tag:).tap do |response|
            raise Discourse::Errors::BaseError, 'Unable to update site_tag' unless response
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError, "Error updating site_tag: #{e.message}"
        end

        def update_topic_tags
          topics = Discourse::DiscourseTopic.where(discourse_site: @discourse_site)
          return unless topics.any?

          # TODO: handle the case of wanting to remove the site tag from all update_topics
          # without setting a new one
          update_topics = CLI::UI::Prompt
                          .confirm('Change site tag for existing topics to  ' \
                                   "{{bold:#{@discourse_site.site_tag}}}?")

          return unless update_topics

          tag_updater = Discourse::Utils::UpdateTagsFrame.new(discourse_site: @discourse_site,
                                                              api_key: @api_key)
          tag_updater.update_site_tag(topics:, old_site_tag: @initial_site_tag)
        end

        def tag_confirm_prompt(tag)
          if tag.empty?
            "Confirm that no tag should be added to notes published from #{@discourse_site.domain}"
          else
            "Is {{bold:#{tag}}} correct?"
          end
        end
      end
    end
  end
end
