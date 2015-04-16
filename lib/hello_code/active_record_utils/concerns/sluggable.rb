module HelloCode
  module ActiveRecordUtils
    module Concerns
      module Sluggable
        extend ActiveSupport::Concern

        included do
          # Be sure to create a valid slug before validating and saving.
          before_validation :set_slug, on: [:create, :update]
          after_validation :delete_slug_errors

          # Scope to query by slug
          scope :by_slug, ->(slug) { where(slug: slug) }

          # Slug must be present
          validates :slug, presence: true, uniqueness: true, length: { maximum: 256 }
        end

        module ClassMethods
          # Find by slug
          def find_by_slug(slug)
            by_slug(slug).take
          end
        end

        def to_param
          slug
        end

        private

        def set_slug
          self.slug = qualify_slug(name.parameterize) if
            name.present? && slug.blank?
        end

        def delete_slug_errors
          errors.delete(:slug)
        end

        def qualify_slug(base_slug)
          tentative_slug = base_slug
          begin
            tentative_slug = "#{base_slug}-#{SecureRandom.random_number(10_000)}"
          end while self.class.exists?(slug: tentative_slug)
          tentative_slug
        end

      end
    end
  end
end
