// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
contract ImageNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;

    struct NFTdata {
        string name;
        string description;}

    mapping(uint => NFTdata) private nameData;

    constructor() ERC721("DEGEN Test", "Genesis NFT layer try")
    {
        tokenCounter = 0;
    }
    function create() public {
        _safeMint(msg.sender, tokenCounter);
        string memory base64Encoded = "ipfs://QmcsrQJMKA9qC9GcEMgdjb9LPN99iDNAg8aQQJLJGpkHxk/1.svg";//string(abi.encodePacked("ipfs://QmcsrQJMKA9qC9GcEMgdjb9LPN99iDNAg8aQQJLJGpkHxk/1.svg"));
        string memory imageURI = base64Encoded;//string(abi.encodePacked("data:image/svg+xml;base64,",base64Encoded));
        nameData[tokenCounter].name = string(abi.encodePacked("Genesis ", Strings.toString(tokenCounter)));
        nameData[tokenCounter].description = "Genesis NFT layer try";
        string memory tokenURI = string(
                abi.encodePacked(
                    abi.encodePacked(
                        bytes('data:application/json;utf8,{"name":"'),
                        nameData[tokenCounter].name,
                        bytes('","description":"'),
                        nameData[tokenCounter].description,
                        bytes('","external_url":"'),
                        "https://forintfinance.com",
                        bytes('","image":"'),
                        imageURI
                    ),
                    abi.encodePacked(
                        bytes('","attributes":['),
                        bytes('{"trait_type": base64String, "value": _value}'),
                        bytes(']}')
                    )));
            
        _setTokenURI(tokenCounter, tokenURI);
        tokenCounter = tokenCounter + 1;
    }

    function changeName(uint256 _tokenID, string memory _name) public {
        require(_tokenID < tokenCounter, "NFT not minted");
        nameData[_tokenID].name = _name;
        (, string memory description) = getData(_tokenID);
        nameData[_tokenID].description = description;
        string memory base64Encoded = "ipfs://QmcsrQJMKA9qC9GcEMgdjb9LPN99iDNAg8aQQJLJGpkHxk/1.svg";//string(abi.encodePacked("ipfs://QmcsrQJMKA9qC9GcEMgdjb9LPN99iDNAg8aQQJLJGpkHxk/1.svg"));
        string memory imageURI = base64Encoded;
        string memory tokenURI = string(
                abi.encodePacked(
                    abi.encodePacked(
                        bytes('data:application/json;utf8,{"name":"'),
                        nameData[_tokenID].name,
                        bytes('","description":"'),
                        nameData[_tokenID].description,
                        bytes('","external_url":"'),
                        "https://forintfinance.com",
                        bytes('","image":"'),
                        imageURI
                    ),
                    abi.encodePacked(
                        bytes('","attributes":['),
                        bytes('{"trait_type": base64String, "value": _value}'),
                        bytes(']}')
                    )));
            
        _setTokenURI(_tokenID, tokenURI);
        
        
        }

    

    function getData(uint256 _tokenID) public view returns(string memory, string memory){
        require(_tokenID < tokenCounter, "NFT not minted");
        return(nameData[_tokenID].name, nameData[_tokenID].description);}


}
