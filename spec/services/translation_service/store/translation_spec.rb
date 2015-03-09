require 'spec_helper'

describe TranslationService::Store::Translation do
  Translation = TranslationService::Store::Translation

  it 'create' do
    groups = [ { translation_key: nil, translations:
       [ { locale: "en-US", translation: "Welcome"
         }, { locale: "fi-FI", translation: "Tervetuloa"
         }
       ]
     }
    ]

    result = Translation.create(community_id: 1, translation_groups: groups )

    expect(result.first[:translations]).to eql groups.first[:translations]
  end
end
