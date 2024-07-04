# frozen_string_literal: true

module Discourse
  module Utils
    class SiteTagFrame
      class << self
        def call(discourse_site:)
          @discourse_site = discourse_site
          tag_frame
        end

        def tag_frame
          site_tag = @discourse_site&.site_tag
          CLI::UI::Frame.open("Tag for #{@discourse_site.domain} notes") do
            if site_tag
              confirm_site_tag(site_tag)
            else
              set_site_tag
            end
          end
        end

        def confirm_site_tag(site_tag)
          change_site_tag = CLI::UI::Prompt
                            .confirm("Notes published to #{@discourse_site.domain} will be  " \
                                     "tagged with #{site_tag}. Would you like to change this?")
          return unless change_site_tag

          confirm = CLI::UI::Prompt
                    .confirm("Confirm that you want to change or remove the #{@discourse_site.domain} tag")
          return unless confirm

          set_site_tag
        end

        def set_site_tag
          puts 'this is a test, this is only a test'
        end
      end
    end
  end
end
