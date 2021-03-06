module.exports = {
    networks: {
        development: {
            host: 'ledger',
            port: 8545,
            network_id: '*' // Match any network id
        },

        local: {
            host: 'localhost',
            port: 8545,
            network_id: '*' // Match any network id
        }
    }
};
