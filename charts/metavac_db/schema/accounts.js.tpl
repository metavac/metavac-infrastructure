conn = Mongo('{{ include "metavac-db.mongo.url" . }}');
db = conn.getDB('{{ include "metavac-db.mongo.name" . }}');

schema = {
    title: "account",
    description: "Document representing an Eth account",
    bsonType: "object",
    required: [
        "_id",
        "balance",
    ],
    properties: {
        _id: {
            bsonType: "binData"
        },
        balance: { 
            bsonType: "long"
        },

        blocks: {
            bsonType: "array",
            is_list: true,
            uniqueItems: true,
            items: {
                bsonType: "binData",
            }
        },
        transactions: {
            bsonType: "array",
            is_list: true,
            uniqueItems: true,
            items: {
                bsonType: "binData"
            }
        },
    }
};

db.createCollection('accounts', {
    "validator": schema
});

db.accounts.createIndex(
    {
        _id: "hashed"
    },
    {
        name: "accounts",
        unique: true
    }
);