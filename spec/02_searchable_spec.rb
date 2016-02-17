require '02_searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Pokemon < SQLObject
      finalize!
    end

    class GymLeader < SQLObject
      self.table_name = 'gym_leaders'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    pokemons = Pokemon.where(name: 'Magikarp')
    pokemon = pokemons.first

    expect(pokemons.length).to eq(1)
    expect(pokemon.name).to eq('Magikarp')
  end

  it '#where can return multiple objects' do
    gym_leaders = GymLeader.where(gym_id: 1)
    expect(gym_leaders.length).to eq(1)
  end

  it '#where searches with multiple criteria' do
    gym_leaders = GymLeader.where(name: 'Brock', gym_id: 1)
    expect(gym_leaders.length).to eq(1)

    gymleader = gym_leaders[0]
    expect(gymleader.name).to eq('Brock')
    expect(gymleader.gym_id).to eq(1)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(GymLeader.where(name: 'Gary')).to eq([])
  end
end
