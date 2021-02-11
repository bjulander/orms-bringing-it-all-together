class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table 
        sql = <<-SQL
        create table if not exists dogs 
        (id integer primary key,
        name text,
        breed text
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        drop table dogs;
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            insert into dogs (name, breed)
            values (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        select *
        from dogs 
        where id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        select *
        from dogs
        where name = ?
        and breed = ?
        limit 1
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else 
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        select *
        from dogs 
        where name = ?
        limit 1
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update 
        sql = <<-SQL
        update dogs
        set name = ?, breed = ?
        where id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end