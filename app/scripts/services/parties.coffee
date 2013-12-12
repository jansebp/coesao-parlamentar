'use strict'

angular.module('votacoesCamaraApp')
  .constant 'parties', {
      'pt': { id: 'pt', label: 'PT', years: ['2002', '2003', '2004', '2005', '2006', '2007'] }
      'pmdb': { id: 'pmdb', label: 'PMDB', years: ['2002', '2003', '2004', '2005', '2006', '2007'] }
      'psol': { id: 'psol', label: 'PSOL', years: ['2007'] }
      'mensaleiros': { id: 'mensaleiros', label: 'Mensaleiros', years: ['2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007'] }
    }
