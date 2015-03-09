module TranslationService::Store::Translation
  CTM = ::CommunityTranslation

  Translation = EntityUtils.define_builder(
    [:translation_key, :mandatory, :string],
    [:locale, :mandatory, :string],
    [:translation])

  module_function

  def create(community_id:, translation_groups: [])
    translation_groups.map { |group|
      enforced_key = group[:translation_key]
      key = Maybe(enforced_key).or_else(gen_translation_uuid(community_id))

      translations = group[:translations].map { |translation|
        translation_hash = {
          community_id: community_id,
          translation_key: key,
          locale: translation[:locale],
          translation: translation[:translation],
          is_key_enforced: enforced_key.present?
        }

        save_translation(translation_hash)
      }

      {
        translation_key: key,
        translations: translations
      }
    }
  end


  # Privates

  def gen_translation_uuid(community_id)
    SecureRandom.uuid
  end

  def create_translation(options)
    options.assert_valid_keys(:community_id, :translation_key, :locale, :translation)
    from_model(CTM.create!(options))
  end

  def save_translation(options)
    options.assert_valid_keys(:community_id, :translation_key, :locale, :translation, :is_key_enforced)

    existing_translation = CTM.where(options.slice(:community_id, :translation_key, :locale)).first

    if options[:is_key_enforced] && existing_translation
      p existing_translation
      update_translation(id: existing_translation.id, translation: options[:translation])
    else
      create_translation(options.slice(:community_id, :translation_key, :locale, :translation))
    end
  end

  def from_model(model)
    Maybe(model)
      .map { |m| EntityUtils.model_to_hash(m)}
      .map { |hash| Translation.call(hash) }
      .or_else(nil)
  end

end
