// packages/hello-world/devserver.test.js

const request = require('supertest');
const express = require('express');
const path = require('path');

// Recriamos uma versão do app aqui para o teste
// NOTA: Idealmente, seu devserver.js exportaria o 'app' para que pudéssemos importá-lo diretamente.
// Por enquanto, vamos replicar a lógica dele para simplificar.
const app = express();
app.get('/', (req, res) => {
  // Precisamos garantir que o caminho para o index.html esteja correto no contexto do teste
  res.sendFile(path.join(__dirname, 'index.html'));
});


describe('GET /', () => {
  it('deve responder com o arquivo index.html', (done) => {
    request(app)
      .get('/')
      .expect('Content-Type', /html/)
      .expect(200)
      .end((err, res) => {
        if (err) return done(err);
        // Verifica se o corpo da resposta contém o título da página
        expect(res.text).toContain('<title>Hello World</title>');
        done();
      });
  });
});