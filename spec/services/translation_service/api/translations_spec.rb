require 'spec_helper'

describe TranslationService::API::Translations do
  TranslationsAPI = TranslationService::API::Api.translations

  before(:each) do
    @community_id = 1
    @translation_key1 = "027268a5-abbf-4191-b6bd-b1e7569b361f"
    @translation_key2 = "blaa-blaa-blaa"
    @locale_en = "en"
    @translation_en = "aa en"
    @locale_fi = "fi-FI"
    @translation_fi = "aa fi"
    @locale_sv = "sv-SE"
    @translations1 =
      [ { locale: @locale_en,
          translation: @translation_en
        },
        { locale: @locale_fi,
          translation: @translation_fi
        }
      ]
    @translations_with_keys =
      @translations1.map { |translation|
        {translation_key: @translation_key1}.merge(translation)
      }
    @translations_groups =
      [ { translation_key: @translation_key1,
          translations: @translations1
        }
      ]
    @translation_groups_with_keys =
      [ { translation_key: @translation_key1,
          translations: @translations_with_keys
        }
      ]
    @creation_hash =
      { community_id: @community_id,
        translation_groups: @translations_groups
      }
  end

  it "POST request with only community_id" do
    result = TranslationsAPI.create(@community_id)
    expect(result[:success]).to eq(false)
    expect(result.members.include?(:error_msg)).to be(true)
    expect(result[:data]).to eq(nil)
  end

  it "POST request with community_id and wrong structure in params" do
    result = TranslationsAPI.create(@community_id, [translations: [{locale: @locale_sv}] ])
    expect(result[:success]).to eq(false)
    expect(result.members.include?(:error_msg)).to be(true)
    expect(result[:data]).to eq(nil)
  end

  it "POST request with community_id and wrong params" do
    result = TranslationsAPI.create(@community_id, {foo: :bar})
    expect(result[:success]).to eq(false)
    expect(result.members.include?(:error_msg)).to be(true)
    expect(result[:data]).to eq(nil)
  end

  it "POST request with community_id and correct params" do
    result = TranslationsAPI.create(@community_id, @translations_groups)
    expect(result.members.include?(:error_msg)).to be(false)
    expect(result[:success]).to eq(true)
    expect(result[:data]).to eq(@translation_groups_with_keys)
  end
end
