class SetFieldsForTeamEvaluations < ActiveRecord::Migration[6.0]
  def change
    fields_config = {
      fields: [
        { label: 'Gedrag', answers: 'rating_5' },
        { label: 'Techniek', answers: 'rating_5' },
        { label: 'Handelingssnelheid', answers: 'rating_5' },
        { label: 'Inzicht/Overzicht', answers: 'rating_5' },
        { label: 'Passen/Trappen', answers: 'rating_5' },
        { label: 'Snelheid', answers: 'rating_5' },
        { label: 'Motoriek', answers: 'rating_5' },
        { label: 'Fysiek', answers: 'rating_5' },
        { label: 'Uithoudingsvermogen', answers: 'rating_5' },
        { label: 'Duelkracht', answers: 'rating_5' }
      ],
      answers: {
        rating_5: [
          { label: 'zeer goed', value: 9 },
          { label: 'goed', value: 8 },
          { label: 'voldoende', value: 6 },
          { label: 'matig', value: 5 },
          { label: 'onvoldoende', value: 4 }
        ]
      }
    }

    TeamEvaluation.update_all(fields: fields_config)
  end
end
