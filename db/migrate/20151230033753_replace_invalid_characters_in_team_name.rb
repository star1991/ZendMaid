class ReplaceInvalidCharactersInTeamName < ActiveRecord::Migration
  def up

    Team.reset_column_information
    Team.find_each do |team|
		team.name = team.name.gsub('&', 'and')
		team.save
    end
  end

  def down
  end
end
