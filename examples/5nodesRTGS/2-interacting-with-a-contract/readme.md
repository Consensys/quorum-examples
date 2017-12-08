
# Running instructions
1. Run `npm install`
2. Run `raft-init.sh` `raft-start.sh` in the geth node
3. Deploy and provision the contracts following the 5nodesRTGS README, steps 4-10. The HTML file has the same contract addresses of a freshly initiated 5NodesRTGS example, change if necessary
4. Replace the IP address from lines `5-8` in `app.js` file. 
5. Run `npm start`
6. Open `index.html` and start playing

It still has a lot of bugs and it is FAR from well written, however it is a good example of a javascript page interacting with Quorum using private transactions.

Thanks to https://github.com/facuspagnuolo/ethereum-spiking from where I copied almost all the code.
