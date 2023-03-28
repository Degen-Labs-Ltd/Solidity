// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


//    .-_'''-.  .-./`)   ___    _  ______         .-''-.  ,---.  ,---. 
//   '_( )_   \ \ .-.').'   |  | ||    _ `''.   .'_ _   \ |   /  |   | 
//  |(_ o _)|  '/ `-' \|   .'  | || _ | ) _  \ / ( ` )   '|  |   |  .' 
//  . (_,_)/___| `-'`"`.'  '_  | ||( ''_'  ) |. (_ o _)  ||  | _ |  |  
//  |  |  .-----..---. '   ( \.-.|| . (_) `. ||  (_,_)___||  _( )_  |  
//  '  \  '-   .'|   | ' (`. _` /||(_    ._) ''  \   .---.\ (_ o._) /  
//   \  `-'`   | |   | | (_ (_) _)|  (_.\.' /  \  `-'    / \ (_,_) /   
//    \        / |   |  \ /  . \ /|       .'    \       /   \     /    
//     `'-...-'  '---'   ``-'`-'' '-----'`       `'-..-'     `---`     
                                                                   


import "./interface.sol";
import "./contract.sol";
import "./abstract.sol";
import "./library.sol";

contract degenNFT is Ownable, ReentrancyGuard, ERC721Royalty {
    
    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    using Strings for uint256;

    string public uriPrefix = "";
    string public uriSuffix = ".json";

    uint256 public costWhitelist = 0.0001 ether;
    uint256 public costPublicSale = 0.0002 ether;
    uint256 public NFTminted;
    address public _royaltyRecipient;
    uint256 public _royaltyPercentage;

    bool public paused = true;
    bool public whitelistMintEnabled = false;
    bool public revealed = false;

    mapping (uint => string) public upgradatedIpfs;
    mapping (uint => bool) public upgradated;
    mapping (uint => string) public averageMonthlyRevenue;
    mapping (address => bool) public whitelisted;
    mapping (address => uint) public minted;

    string public tokenName = "DEGEN NFT COLLECTION";
    string public tokenSymbol = "DNC";
    uint256 public maxSupply = 10420;
    uint256 public mintableSupply = 10000;
    uint256 public maxMintAmountPerTx = 200;
    string public hiddenMetadataUri = "ipfs://bafybeibgmbc3cfamhby6z43jr2pnx3s2u7f22qvbp2hiptisilfdccq3z4";

    
    constructor() ERC721A(tokenName, tokenSymbol) {
            maxSupply = maxSupply;
            setMaxMintAmountPerTx(maxMintAmountPerTx);
            setHiddenMetadataUri(hiddenMetadataUri);}

    //NFT info

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;}

    function check_all_token_owned(address _wallet_address) public view returns (uint256[] memory valueReturn){
        require(totalSupply() > 0, "0 NFT Minted");
        uint256 mintedNFT = totalSupply();
        uint256 counter;
        uint256[] memory value = new uint256[](balanceOf(_wallet_address));
        for (uint i = 1; i <= mintedNFT; i++) {
            if(ownerOf(i) == _wallet_address){
                value[counter] = i;
                counter ++;}}         
        return value;}

    //Modifier

    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");
        require(totalSupply() + _mintAmount <= mintableSupply, "Mintable supply exceeded!");
        _;}

    modifier mintPriceCompliance(uint256 _mintAmount) {
        if(whitelistMintEnabled == true && paused == true){
            require(msg.value >= costWhitelist * _mintAmount, "Insufficient funds!");}
        if(paused == false){
            require(msg.value >= costPublicSale * _mintAmount, "Insufficient funds!");}
        _;}

    //Setting

    function setCostWhitelist(uint256 _cost) public onlyOwner {
        costWhitelist = _cost;}

    function setCostPublicSale(uint256 _cost) public onlyOwner {
        costPublicSale = _cost;}

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;}

    function royaltyInfo(uint256 tokenId, uint256 value) public view override returns (address, uint256) {
        require(_exists(tokenId), "Query for nonexistent token");
        uint256 royaltyAmount = (value * _royaltyPercentage) / 100;
        return (_royaltyRecipient, royaltyAmount);
    }

    function setRoyalties(address receiver, uint256 royaltyPercentage) external onlyOwner {
        require(receiver != address(0), "Royalty recipient cannot be zero address");
        require(royaltyPercentage <= 100, "Royalty percentage must be less than or equal to 100");

        _royaltyRecipient = receiver;
        _royaltyPercentage = royaltyPercentage;
    }

    //Mint and Burn

    function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
        require(!paused, 'The contract is paused!');
        minted[_msgSender()] = minted[_msgSender()] + _mintAmount;//CHECK
        require(minted[_msgSender()] <= maxMintAmountPerTx, "Max quantity reached");
        NFTminted += _mintAmount;
            _safeMint(_msgSender(), _mintAmount);}

    function burn(uint256 tokenId) public {
        _burn(tokenId, true);}

    function mintForAddress(uint256 _mintAmount, address _receiver) public onlyOwner {
        require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
        //Minted by Owner without any cost, doesn't count on minted quantity
        NFTminted += _mintAmount;
        _safeMint(_receiver, _mintAmount);}

    //URI

    function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;}

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;}

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;}

    function upgradeNft(uint256 _tokenId, string memory ipfs) public onlyOwner {
        upgradated[_tokenId] = true;
        upgradatedIpfs[_tokenId] = ipfs;}

     function resetNft(uint256 _tokenId) public onlyOwner {
        upgradated[_tokenId] = false;
        upgradatedIpfs[_tokenId] = "";} 

    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');
        if (revealed == false) {
            return hiddenMetadataUri;}
        else {
            if(upgradated[_tokenId] == false) {
                string memory currentBaseURI = _baseURI();
                return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix)): '';}
            else {
                return upgradatedIpfs[_tokenId];}
        }
    }
    
    //Whitelist

    function whitelistAddress (address[] memory _addr) public onlyOwner() {
        for (uint i = 0; i < _addr.length; i++) {
            if(whitelisted[_addr[i]] == false){
                whitelisted[_addr[i]] = true;}}}

    function blacklistWhitelisted(address _addr) public onlyOwner() {
        require(whitelisted[_addr], "Account is already Blacklisted");
        whitelisted[_addr] = false;}

    function whitelistMint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
        require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
        require(whitelisted[_msgSender()], "Account is not in whitelist");
        minted[_msgSender()] = minted[_msgSender()] + _mintAmount;//CHECK
        require(minted[_msgSender()] <= maxMintAmountPerTx, "Max quantity reached");
        NFTminted += _mintAmount;
        _safeMint(_msgSender(), _mintAmount);}

    //State

    function setPaused(bool _state) public onlyOwner {
        paused = _state;}

    function setWhitelistMintEnabled(bool _state) public onlyOwner {
        whitelistMintEnabled = _state;}

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;}


    function withdraw() public onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}('');
        require(os);}
        
    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;}} 
