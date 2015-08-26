module Mail
  module Filters
    class BodyFilter < BaseFilter
      MAX_LINKS = 3

      BLACKLISTED_PHRASES   = ['click here', 'password reset', 'new password', 'activate account', 'your login',
                               'unsubscribe', 'manage preferences', 'manage subscription', 'contact us', "password reset",
                               'manage my subscription', 'stop receiving email', 'stop receiving these',
                               'change your settings', 'dear customer', 'generated by Gmail', 'request received',
                               'online version']

      BLACKLISTED_LINKS     = ['Privacy', 'Support', 'Blog', 'Legal', 'Terms', 'Terms of Use', 'Facebook', 'Twitter', 'Click Here',
                               'Help Center', 'Security']

      def self.filtered?(body)
        blacklisted_words?(BLACKLISTED_PHRASES, body) # || too_many_links?(body)
      end

      private
      def self.too_many_links?(body)
        link_count(body) > MAX_LINKS
      end

      def self.link_count(body)
        doc = Nokogiri::HTML(body, 'utf-8')
        doc.search("a").reject do |a|
          BLACKLISTED_LINKS.any?{|bl| a.text =~ /#{bl}/i}
        end.size
      end
    end
  end
end
