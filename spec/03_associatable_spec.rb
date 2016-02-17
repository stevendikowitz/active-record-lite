require '03_associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('gym')

      expect(options.foreign_key).to eq(:gym_id)
      expect(options.class_name).to eq('Gym')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new(
        'gym_leader',
        foreign_key: :gym_leader_id,
        class_name: 'GymLeader',
        primary_key: :gym_leader_id
      )

      expect(options.foreign_key).to eq(:gym_leader_id)
      expect(options.class_name).to eq('GymLeader')
      expect(options.primary_key).to eq(:gym_leader_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('pokemons', 'GymLeader')

      expect(options.foreign_key).to eq(:gymleader_id)
      expect(options.class_name).to eq('Pokemon')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new(
        'pokemons',
        'GymLeader',
        foreign_key: :gym_leader_id,
        class_name: 'Type',
        primary_key: :gym_leader_id
      )

      expect(options.foreign_key).to eq(:gym_leader_id)
      expect(options.class_name).to eq('Type')
      expect(options.primary_key).to eq(:gym_leader_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Pokemon < SQLObject
        self.finalize!
      end

      class GymLeader < SQLObject
        self.table_name = 'gym_leaders'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('GymLeader')
      expect(options.model_class).to eq(GymLeader)

      options = HasManyOptions.new('pokemons', 'GymLeader')
      expect(options.model_class).to eq(Pokemon)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('GymLeader')
      expect(options.table_name).to eq('gym_leaders')

      options = HasManyOptions.new('pokemons', 'GymLeader')
      expect(options.table_name).to eq('pokemons')
    end
  end
end

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

  describe '#belongs_to' do
    let(:onyx) { Pokemon.find(1) }
    let(:brock) { GymLeader.find(1) }

    it 'fetches `GymLeader` from `Pokemon` correctly' do
      expect(onyx).to respond_to(:GymLeader)
      gymleader = onyx.GymLeader

      expect(gymleader).to be_instance_of(GymLeader)
      expect(gymleader.name).to eq('Brock')
    end

    it 'fetches `gym` from `GymLeader` correctly' do
      expect(brock).to respond_to(:gym)
      gym = brock.gym

      expect(gym).to be_instance_of(Gym)
      expect(gym.name).to eq('Rock')
    end

    it 'returns nil if no associated object' do
      stray_pokemon = Pokemon.find(5)
      expect(stray_pokemon.GymLeader).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:surge) { GymLeader.find(3) }
    let(:surge_gym) { Gym.find(3) }

    it 'fetches `pokemons` from `GymLeader`' do
      expect(surge).to respond_to(:pokemons)
      pokemons = surge.pokemons

      expect(pokemons.length).to eq(1)

      expected_pokemon_name = "Electrode"
      pokemon = pokemons.first

      expect(pokemon).to be_instance_of(Pokemon)
      expect(pokemon.name).to eq(expected_pokemon_name)
    end

    it 'fetches `gym_leaders` from `gym`' do
      expect(surge_gym).to respond_to(:gym_leaders)
      gym_leaders = surge_gym.gym_leaders

      expect(gym_leaders.length).to eq(1)
      expect(gym_leaders[0]).to be_instance_of(GymLeader)
      expect(gym_leaders[0].name).to eq('Lt. Surge')
    end
  end
end
