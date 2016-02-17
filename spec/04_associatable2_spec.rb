require '04_associatable2'

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Pokemon < SQLObject
      belongs_to :GymLeader, foreign_key: :gym_leader_id

      finalize!
    end

    class GymLeader < SQLObject
      self.table_name = 'gym_leaders'

      has_many :pokemons, foreign_key: :gym_leader_id
      belongs_to :gym

      finalize!
    end

    class Gym < SQLObject
      has_many :gym_leaders

      finalize!
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      Pokemon_assoc_options = Pokemon.assoc_options
      GymLeader_options = Pokemon_assoc_options[:GymLeader]

      expect(GymLeader_options).to be_instance_of(BelongsToOptions)
      expect(GymLeader_options.foreign_key).to eq(:gym_leader_id)
      expect(GymLeader_options.class_name).to eq('GymLeader')
      expect(GymLeader_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Pokemon.assoc_options).to have_key(:GymLeader)
      expect(GymLeader.assoc_options).to_not have_key(:GymLeader)

      expect(GymLeader.assoc_options).to have_key(:gym)
      expect(Pokemon.assoc_options).to_not have_key(:gym)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Pokemon
        has_one_through :gym, :GymLeader, :gym

        self.finalize!
      end
    end

    let(:pokemon) { Pokemon.find(1) }

    it 'adds getter method' do
      expect(pokemon).to respond_to(:gym)
    end

    it 'fetches associated `gym` for a `pokemon`' do
      gym = pokemon.gym

      expect(gym).to be_instance_of(Gym)
      expect(gym.name).to eq('Rock')
    end
  end
end
