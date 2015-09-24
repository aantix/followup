module Mail
  module Filters
    class FromFilter < BaseFilter
      BLACKLISTED_EMAILS    = ["abuse@", "academic.administrator@", "accounts@", "account-update@", "admin@", "administrator@",
                               "advice@", "alert@", "alerts@", "all@", "analysis@", "arts@", "assistant@",
                               "auto-confirm@", "billing@", "birmingham@", "bizdev@", "bookings@", "boss@", "confirm@",
                               "bot@", "bristol@", "bursar@", "bury@", "careers@", "career@", "ceo@", "clerks@", "contact.us@",
                               "contact@", "contactus@", "customercare@", "customerservice@", "customersupport@",
                               "deals@", "deploy@", "design@", "details@", "development@", "digest@", "discussions@",
                               "dns@", "do_not_reply@", "do-not-reply@", "donotreply", "editor@", "education@", "email@", "enq@", "enquire@", "enquires@",
                               "enquiries@", "enquiry@", "enquries@", "equipment@", "estate@", "everyone@", "facebook.com",
                               "facebookappmail.com", "facilities@", "farmer@", "freight@", "ftp@", "geico@", "gen.enquiries@",
                               "general.enquiries@", "general@", "genoffice@", "@googlegroups.com", "groups@",
                               "head@", "headoffice@", "headteacher@", "hello@", "help@", "helpdesk@", "hi@", "hiredesk@",
                               "hospitality@", "hostmaster@", "hq@", "hr@", "info@", "infodesk@", "informatica@", "information@",
                               "institute@", "insurance@", "instructor@", "investorrelations@", "invitations", "jira@",
                               "jobs-listings@", "jobs@", "law@", "london@", "maintenance@", "mail@", "mailbox@", "mailer-daemon@",
                               "main.office@", "manager@", "manchester@", "marketplace-messages@", "marketing@", "md@",
                               "media@", "member@", "@marketplace.amazon.com", "members@", "membership@", "news@",
                               "newsletter@", "nntp@", "noc@", "noreply", "no-reply@", "notifications@", "notify@", "notifier@",
                               "nytdirect@", "office@", "officeadmin@", "order@", "feedback@",
                               "orders@", "payroll@", "post@", "postbox@", "postmaster@", "pr@", "president@", "privacy@",
                               "property@", "reception@", "recruit@", "recruitment@", "renewals@", "rental@",
                               "replies@", "reply@", "request@", "reservation@", "reservations@", "root@",
                               "sales@", "salesinfo@", "school.office@", "schooladmin@",
                               "schoolinfo@", "schooloffice@", "secretary@", "security@", "server@",
                               "service@", "services@", "ship-confirm@", "slashdot.org", "smtp@", "spam@", "studio@", "subscribe@",
                               "supervisor@", "support@", "technique@", "theoffice@", "undisclosed-recipients@", "update@",
                               "uk-info@", "usenet@", "uucp@", "vets@", "www@", "webadmin@", "webmail@", "webmaster@",
                               "whois@", "yahoogroups.com", "builds@", "ebay@"]

      attr_reader :from, :owner

      def initialize(from, owner)
        @from  = from
        @owner = owner
      end

      def filtered?
        blacklisted_words?(BLACKLISTED_EMAILS, from) || same_addressee(from, owner)
      end

      private
      def same_addressee(from, owner)
        from == owner
      end

    end
  end
end
