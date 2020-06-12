pragma solidity ^0.4.0;

contract Loteria {
    address dono;
    string nomeDono;
    uint inicio;
    
    struct Sorteio {
        uint data;
        uint numeroSorteado;
        address remetente;
        uint countPalpites;
    }
    
    Sorteio[] sorteios;
    
    mapping(address => uint) palpites;
    address[] palpiteiros;
    address[] ganhadores;
    
    constructor(string _nome) public{
        dono = msg.sender;
        nomeDono = _nome;
        inicio = now;
    }
    
    modifier apenasDono(){
        require(msg.sender == dono, 'Apenas o dono do contrato pode fazer isso.');
        _;
    }
    
    modifier excetoDono(){
        require(msg.sender != dono, 'O dono do contrato não pode executar essa ação');
        _;
    }
    
    event TrocoEnviado(address pagante, uint troco);
    event PalpiteRegistrado(address remetente, uitn palpite);
    
    function enviarPalpite(uint palpiteEnviado) payable public{ //excetoDono(){
        require(palpiteEnviado >= 1 && palpiteEnviado <= 4, 'Vocˆê tem que escolher um valor entre 1 e 4.');
        
        require(palpites[msg.sender] == 0, 'Apenas um palpite pode ser dado por sorteio.')
    }
}