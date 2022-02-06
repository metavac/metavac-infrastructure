conn = Mongo('{{ include "metavac-db.mongo.url" . }}');
db = conn.getDB('{{ include "metavac-db.mongo.name" . }}');

schema = {
    title: "block",
    description: "Document representing an Eth block",
    bsonType: "object",
    required: [
        "_id",
        "size",
        "difficulty",
        "baseFeePerGas",
        "gasLimit",
        "gasUsed",
        "hash",
        "parentHash",
        "miner",
        "extraData",
        "logsBloom",
        "receiptsRoot",
        "stateRoot",
        "transactionsRoot",
        "sha3Uncles"
    ],
    properties: {
        _id: {
            // Block number/height is used as _id
            bsonType: "long"
        },
        timestamp: {
            bsonType: "timestamp"
        },
        nonce: {
            bsonType: "int"
        },
        size: {
            bsonType: "int"
        },
        difficulty: {
            bsonType: "int"
        },
        baseFeePerGas: {
            bsonType: "int"
        },
        gasLimit: {
            bsonType: "int"
        },
        gasUsed: {
            bsonType: "int"
        },
        hash: {
            bsonType: "binData"
        },
        parentHash: {
            bsonType: "binData"
        },
        mixHash: {
            bsonType: "binData"
        },
        miner: {
            bsonType: "binData"
        },
        extraData: {
            bsonType: "binData"
        },
        logsBloom: {
            bsonType: "binData"
        },
        stateRoot: {
            bsonType: "binData"
        },
        receiptsRoot: {
            bsonType: "binData"
        },
        transactionsRoot: {
            bsonType: "binData"
        },
        transactions: {
            bsonType: "array",
            is_list: true,
            uniqueItems: true,
            items: {
                title: "transaction",
                description: "Document representing an Eth transaction",
                bsonType: "object",
                required: [
                    "_id", // Hash
                    "from",
                    "gas",
                    "gasPrice",
                    "input",
                    "nonce",
                    "value",
                    "v",
                    "r",
                    "s"
                ],
                properties: {
                    _id: {
                        bsonType: "binData"
                    },
                    blockNumber: {
                        bsonType: "int"
                    },
                    nonce: {
                        bsonType: "int"
                    },
                    transactionIndex: {
                        bsonType: "int"
                    },
                    gas: {
                        bsonType: "int"
                    },
                    gasPrice: {
                        bsonType: "int"
                    },
                    gasUsed: {
                        bsonType: "int"
                    },
                    blockHash: {
                        bsonType: "binData"
                    },
                    type: {
                        bsonType: "binData"
                    },
                    from: {
                        bsonType: "binData"
                    },
                    to: {
                        bsonType: "binData"
                    },
                    input: {
                        bsonType: "binData"
                    },
                    value: {
                        bsonType: "int"
                    },
                    method: {
                        bsonType: "string"
                    },
                    v: {
                        bsonType: "binData"
                    },
                    r: {
                        bsonType: "binData"
                    },
                    s: {
                        bsonType: "binData"
                    }
                }
            }
        },
        sha3Uncles: {
            bsonType": "binData"
        },
        uncles: {
            bsonType: "array",
            is_list: true,
            uniqueItems: true,
            items: {
                bsonType: "binData"
            }
        }
    }
};

db.createCollection('blocks', {
    validator: schema
});

db.blocks.createIndex(
    {
        _id: 1,
        hash: 1
    },
    {
        name: "block_id",
        unique: true
    }
);

db.blocks.createIndex(
    {
        miner: 1,
        timestamp: 1
    },
    {
        name: "block_metadata",
        unique: false
    }
);

db.blocks.createIndex(
    {
        "transactions._id": 1,
    },
    {
        name: "transactions_id",
        unique: true
    }
);

db.blocks.createIndex(
    {
        "transactions.from": 1,
        "transactions.to": 1,
    },
    {
        name: "transactions_recipients",
        unique: false
    }
);