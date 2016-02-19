require 'sql_object'
require 'db_connection'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Pokemon < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Pokemon)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Pokemon.table_name).to eq('pokemons')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class GymLeader < SQLObject
          self.table_name = 'gym_leaders'
        end

        expect(GymLeader.table_name).to eq('gym_leaders')

        Object.send(:remove_const, :GymLeader)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Pokemon.columns).to eq([:id, :name, :gym_leader_id])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Pokemon.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        pokemon_attributes = {name: 'Meowth'}
        c = Pokemon.new
        c.instance_variable_set('@attributes', pokemon_attributes)

        expect(c.attributes).to equal(pokemon_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        c = Pokemon.new

        expect(c.instance_variables).not_to include(:@attributes)
        expect(c.attributes).to eq({})
        expect(c.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Pokemon < SQLObject
        self.finalize!
      end

      class GymLeader < SQLObject
        self.table_name = 'gym_leaders'

        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Pokemon)
      Object.send(:remove_const, :GymLeader)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        c = Pokemon.new
        expect(c.respond_to? :something).to be false
        expect(c.respond_to? :name).to be true
        expect(c.respond_to? :id).to be true
        expect(c.respond_to? :gym_leader_id).to be true
      end

      it 'creates setter methods for each column' do
        c = Pokemon.new
        c.name = "Pikachu"
        c.id = 209
        c.gym_leader_id = 2
        expect(c.name).to eq 'Pikachu'
        expect(c.id).to eq 209
        expect(c.gym_leader_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        c = Pokemon.new
        c.instance_variable_set(:@attributes, {name: "Pikachu"})
        expect(c.name).to eq 'Pikachu'
      end

      it 'created setter methods use attributes hash to store data' do
        c = Pokemon.new
        c.name = "Pikachu"

        expect(c.instance_variables).to include(:@attributes)
        expect(c.instance_variables).not_to include(:@name)
        expect(c.attributes[:name]).to eq 'Pikachu'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do
        # We have to set method expectations on the Pokemon object *before*
        # #initialize gets called, so we use ::allocate to create a
        # blank Pokemon object first and then call #initialize manually.
        c = Pokemon.allocate

        expect(c).to receive(:name=).with('Sandshrew')
        expect(c).to receive(:id=).with(100)
        expect(c).to receive(:gym_leader_id=).with(4)

        c.send(:initialize, {name: 'Sandshrew', id: 100, gym_leader_id: 4})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Pokemon.new(mentor: 'Professor Oak')
        end.to raise_error "unknown attribute 'mentor'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        pokemons = Pokemon.all
        expect(pokemons.count).to eq(5)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'Pokemon1', gym_leader_id: 1 },
          { name: 'Pokemon2', gym_leader_id: 2 }
        ]

        pokemons = Pokemon.parse_all(hashes)
        expect(pokemons.length).to eq(2)
        hashes.each_index do |i|
          expect(pokemons[i].name).to eq(hashes[i][:name])
          expect(pokemons[i].gym_leader_id).to eq(hashes[i][:gym_leader_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        pokemons = Pokemon.all
        pokemons.each { |pokemon| expect(pokemon).to be_instance_of(Pokemon) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        c = Pokemon.find(1)

        expect(c).to be_instance_of(Pokemon)
        expect(c.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Pokemon.find(123)).to be_nil
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        pokemon = Pokemon.new(id: 123, name: 'Pokemon1', gym_leader_id: 1)

        expect(pokemon.attribute_values).to eq([123, 'Pokemon1', 1])
      end
    end

    describe '#insert' do
      let(:pokemon) { Pokemon.new(name: 'Meowth', gym_leader_id: 1) }

      before(:each) { pokemon.insert }

      it 'inserts a new record' do
        expect(Pokemon.all.count).to eq(6)
      end

      it 'sets the id once the new record is saved' do
        expect(pokemon.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        # pull the Pokemon again
        Pokemon2 = Pokemon.find(pokemon.id)

        expect(Pokemon2.name).to eq('Meowth')
        expect(Pokemon2.gym_leader_id).to eq(1)
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        gymleader = GymLeader.find(2)
        gymleader.name = 'Giovanni'
        gymleader.update

        # pull the GymLeader again
        gymleader = GymLeader.find(2)
        expect(gymleader.name).to eq('Giovanni')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        gymleader = GymLeader.new
        expect(gymleader).to receive(:insert)
        gymleader.save
      end

      it 'calls #update when record already exists' do
        gymleader = GymLeader.find(1)
        expect(gymleader).to receive(:update)
        gymleader.save
      end
    end
  end
end
