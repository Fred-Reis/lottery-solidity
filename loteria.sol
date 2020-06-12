pragma solidity ^0.4.0;

contract Loteria {
    address dono;
    string nomeDono;
    uint256 inicio;

    struct Sorteio {
        uint256 data;
        uint256 numeroSorteado;
        address remetente;
        uint256 countPalpites;
    }

    Sorteio[] sorteios;

    // mapping para pegar o palpite pelo endereço do apostador
    mapping(address => uint256) palpites;
    address[] palpiteiros;
    address[] ganhadores;

    constructor(string _nome) public {
        dono = msg.sender;
        nomeDono = _nome;
        inicio = now;
    }

    // modifier para apenas o dono executar aquela ação
    modifier apenasDono() {
        require(
            msg.sender == dono,
            "Apenas o dono do contrato pode fazer isso."
        );
        _;
    }

    // modifier para apenas o dono não executar aquela ação
    modifier excetoDono() {
        require(
            msg.sender != dono,
            "O dono do contrato não pode executar essa ação"
        );
        _;
    }

    // event para registrar o troco enviado
    event TrocoEnviado(address pagante, uint256 troco);
    // event para emitir palpite registrado
    event PalpiteRegistrado(address remetente, uint256 palpite);

    function enviarPalpite(uint256 palpiteEnviado) public payable {
        //excetoDono(){
        require(
            palpiteEnviado >= 1 && palpiteEnviado <= 4,
            "Você tem que escolher um valor entre 1 e 4."
        );

        require(
            palpites[msg.sender] == 0,
            "Apenas um palpite pode ser dado por sorteio."
        );

        require(msg.value >= 1 ether, "A taxa para palpitar é 1 ether");

        //calcula e envia o troco
        uint256 troco = msg.value - 1 ether;
        if (troco > 0) {
            msg.sender.transfer(troco);
            emit TrocoEnviado(msg.sender, troco);
        }

        // registra palpite
        palpites[msg.sender] = palpiteEnviado;
        palpiteiros.push(msg.sender);
        emit PalpiteRegistrado(msg.sender, palpiteEnviado);
    }

    // função para pegar um palpite pelo endereço
    function verificaMeuPalpite() public view returns (uint256 palpite) {
        require(
            palpites[msg.sender] > 0,
            "Você ainda não deu o seu palpite neste sorteio."
        );

        return palpites[msg.sender];
    }

    // função para pegar a quantidade de palpites
    function contarPalpites() public view returns (uint256 count) {
        return palpiteiros.length;
    }

    // event para informar o resultado do sorteio
    event SorteioPostado(uint256 resultado);
    // event para emitir a distribuição dos prêmios
    event PremiosEnviados(uint256 premioTotal, uint256 premioIndividual);

    // função para sortear um número usando o mofifier apenasDono()
    function sortear() public apenasDono() returns (uint8 _numeroSorteado) {
        require(
            now > inicio + 1 minutes,
            "O sorteio só pode ser feito após o intervalo de 1 minuto"
        );

        require(
            palpiteiros.length >= 1,
            "Um mínimo de 1 pessoa é exigido para poder sortear"
        );

        // sortear um numero aleatório
        // isso não funcionou
        // uint8 numeroSorteado = uint8(keccak256(abi.encodePacked(blockhash(block.number - 1))))/64 +1;
        uint8 numeroSorteado = 1;

        // // colocando o sorteio no array de sorteios
        sorteios.push(
            Sorteio({
                data: now,
                numeroSorteado: numeroSorteado,
                remetente: msg.sender,
                countPalpites: palpiteiros.length
            })
        );

        // // emissão do event para informar o resultado do sorteio
        emit SorteioPostado(numeroSorteado);

        // // procura por ganhadores
        for (uint256 p = 0; p < palpiteiros.length; p++) {
            address palpiteiro = palpiteiros[p];

            if (palpites[palpiteiro] == numeroSorteado) {
                ganhadores.push(palpiteiro);
            }
            delete palpites[palpiteiro];
        }

        uint256 premioTotal = address(this).balance;

        if (ganhadores.length > 0) {
            uint256 premio = premioTotal / ganhadores.length;

            // envio de premios
            for (p = 0; p < ganhadores.length; p++) {
                ganhadores[p].transfer(premio);
            }
            emit PremiosEnviados(premioTotal, premio);
        }

        //resetar o sorteio
        delete palpiteiros;
        delete ganhadores;

        return numeroSorteado;
    }

    function kill() public apenasDono() {
        dono.transfer(address(this).balance);
        selfdestruct(dono);
    }
}
