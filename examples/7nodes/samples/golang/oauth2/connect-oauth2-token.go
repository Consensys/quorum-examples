package main

import (
	"context"
	"crypto/tls"
	"net/http"
	"net/url"

	ethrpc "github.com/ethereum/go-ethereum/rpc"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"
)

func main() {
	ctx := context.Background()

	// TLS check skip start - you should not need this if your oauth2 server has a proper certificate
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	sslcli := &http.Client{Transport: tr}
	ctx = context.WithValue(ctx, oauth2.HTTPClient, sslcli)
	// TLS check skip end

	conf := &clientcredentials.Config{
		ClientID:       "PS1",
		ClientSecret:   "foofoo",
		Scopes:         []string{"rpc://eth_*", "rpc://quorumExtension_*", "rpc://rpc_modules", "psi://PS1?self.eoa=0x0&node.eoa=0x0"},
		TokenURL:       "https://localhost:4444/oauth2/token",
		EndpointParams: url.Values{"audience": {"Node1"}},
	}

	token, err := conf.Token(ctx)
	if err != nil {
		println(err.Error())
		return
	}

	rpcClient, err := ethrpc.DialHTTPWithClient("https://localhost:22000?PSI=PS1", sslcli)
	if err != nil {
		println(err.Error())
		return
	}
	var f ethrpc.HttpCredentialsProviderFunc = func(ctx context.Context) (string, error) {
		// optionally to refresh the token if necessary
		return "Bearer " + token.AccessToken, nil
	}
	// configure rpc.Client with preauthenticated token
	authenticatedClient := rpcClient.WithHTTPCredentials(f)

	var res string
	err = authenticatedClient.Call(&res, "eth_blockNumber")
	if err != nil {
		println(err.Error())
		return
	}
	println("Block number: " + res)
}
