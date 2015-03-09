module TranslationService
  module DataTypes
    module Translation
      CreateTranslationGroups = EntityUtils.define_builder(
        [:translation_groups, :array, default:[]])

      CreateTranslationGroup = EntityUtils.define_builder(
        [:translations, :mandatory, :array],
        [:translation_key, :string])

      CreateTranslation = EntityUtils.define_builder(
        [:locale, :mandatory, :string],
        [:translation, :mandatory, :string],
        [:translation_key, :string])

      module_function

      def validate_translation_groups(opts)
        groups = CreateTranslationGroups.call(opts)

        groups[:translation_groups].map do |g|
          group = CreateTranslationGroup.call(g)

          group[:translations].map do |t|
            CreateTranslation.call(t)
          end

          group
        end

        groups
      end
    end
  end
end
