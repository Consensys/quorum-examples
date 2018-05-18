module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
	networks: {
		development: {
   	   		host: "localhost",
    		port: 8545,
      		network_id: "*" // Match any network id
		},
		n1: {
			host: "127.0.0.1",
			port: 22000,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
		n2: {
			host: "127.0.0.1",
			port: 22001,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
		n3: {
			host: "127.0.0.1",
			port: 22002,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
		n4: {
			host: "127.0.0.1",
			port: 22003,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
		n5: {
			host: "127.0.0.1",
			port: 22004,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
		n6: {
			host: "127.0.0.1",
			port: 22005,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
		n7: {
			host: "127.0.0.1",
			port: 22006,
			network_id : "*",
			gasPrice : 0,
			gas : 4500000
		},
	}
};
