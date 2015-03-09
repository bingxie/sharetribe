module TranslationService::API
  class Translations
    TranslationStore = TranslationService::Store::Translation

    def create(community_id, translation_groups = [])
      if translation_groups.empty?
        msg = "You must specify 'translation_groups' as an array of hash-objects containing translation_key and array of translations - like: [ { translation_key: nil, translations: [ { locale: 'en-US' , translation: 'Hi!'}, { locale: 'fi-FI', translation: 'Moi!'}]}]"
        Result::Error.new(msg)
      end
      begin
        groups = TranslationService::DataTypes::Translation
            .validate_translation_groups({translation_groups: translation_groups})

        Result::Success.new(TranslationStore.create({
                                community_id: community_id,
                                translation_groups: groups[:translation_groups]
                              }))
      rescue Exception => error
        msg = "Translation_groups data structure is not valid"
        Result::Error.new(msg)
      end
    end
  end
end
