{"ops": [

    {"insert": {"object": {"globals": {
        "ref": {},
        "data": {
            "party_prototype": {"id": 42},
            "providers": {"value": [{"id": 1}, {"id": 2}, {"id": 3}]},
            "system_account_set": {"value": {"id": 1}},
            "external_account_set": {"value": {"id": 1}},
            "inspector": {"value": {"id": 1}},
            "default_contract_template": {"id": 2},
            "common_merchant_proxy": {"id": 1000}
        }
    }}}},

    {"insert": {"object": {"system_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"external_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "income": $(${CURDIR}/create-account.sh RUB $*),
                    "outcome": $(${CURDIR}/create-account.sh RUB $*)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"party_prototype": {
        "ref": {"id": 42},
        "data": {
            "shop": {
                "shop_id": "TEST",
                "category": {"id": 1},
                "currency": {"symbolic_code": "RUB"},
                "details": {"name": "SUPER DEFAULT SHOP"},
                "location": {"url": ""}
            },
            "contract": {
                "contract_id": "TEST",
                "test_contract_template": {"id": 1},
                "payout_tool": {
                    "payout_tool_id": "TEST",
                    "payout_tool_info": {"bank_account": {
                        "account": "01234567890123456789",
                        "bank_name": "TEST BANK",
                        "bank_post_account": "01234567890123456789",
                        "bank_bik": "123456789"
                    }},
                    "payout_tool_currency": {"symbolic_code": "RUB"}
                }
            }
        }
    }}}},

    {"insert": {"object": {"inspector": {
        "ref": {"id": 1},
        "data": {
            "name": "Kovalsky",
            "description": "World famous inspector Kovalsky at your service!",
            "proxy": {
                "ref": {"id": 100},
                "additional": {
                    "risk_score": "high"
                }
            }
        }
    }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 1},
        "data": {
            "term_sets": [
                {
                    "action_time": {},
                    "terms": {
                        "payments": {
                            "currencies": {"value": [
                                {"symbolic_code": "RUB"}
                            ]},
                            "categories": {"value": [
                                {"id": 1}
                            ]},
                            "payment_methods": {"value": [
                                {"id": {"bank_card": "visa"}},
                                {"id": {"bank_card": "mastercard"}},
                                {"id": {"bank_card": "nspkmir"}}
                            ]},
                            "cash_limit": {"decisions": [
                                {
                                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                                    "then_": {"value": {
                                        "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                                        "upper": {"exclusive": {"amount": 4200000, "currency": {"symbolic_code": "RUB"}}}
                                    }}
                                }
                            ]},
                            "fees": {"decisions": [
                                {
                                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                                    "then_": {"value": [
                                        {
                                            "source": {"merchant": "settlement"},
                                            "destination": {"system": "settlement"},
                                            "volume": {"share": {"parts": {"p": 45, "q": 1000}, "of": "payment_amount"}}
                                        }
                                    ]}
                                }
                            ]},
                            "hold_lifetime": {"seconds": 3}
                        }
                    }
                }
            ]
        }
    }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 2},
        "data": {
            "parent_terms" : {"id": 1},
            "term_sets": [
                {
                    "action_time": {},
                    "terms": {
                        "payments": {
                            "categories": {"value": [
                                {"id": 2}
                            ]}
                        }
                    }
                }
            ]
        }
    }}}},

    {"insert": {"object": {"contract_template": {
        "ref": {"id": 1},
        "data": {
            "terms": {"id": 1}
        }
    }}}},

    {"insert": {"object": {"contract_template": {
        "ref": {"id": 2},
        "data": {
            "terms": {"id": 2}
        }
    }}}},

    {"insert": {"object": {"currency": {
        "ref": {"symbolic_code": "RUB"},
        "data": {
            "name": "Russian rubles",
            "numeric_code": 643,
            "symbolic_code": "RUB",
            "exponent": 2
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 1},
        "data": {
            "name": "Basic test category",
            "description": "Basic test category for mocketbank provider",
            "type": "test"
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 2},
        "data": {
            "name": "Quasi-live test category",
            "description": "Quasi-live test category for mocketbank provider",
            "type": "live"
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 3},
        "data": {
            "name": "Pastry VTB24",
            "description": "Items of food consisting of sweet pastry with a cream, jam, or fruit filling (only VTB24 clients should enjoy it)",
            "type": "live"
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 4},
        "data": {
            "name": "Pastry TCS",
            "description": "Items of food consisting of sweet pastry with a cream, jam, or fruit filling (only TCS clients should enjoy it)",
            "type": "live"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "visa"}},
        "data": {
            "name": "VISA",
            "description": "VISA bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "mastercard"}},
        "data": {
            "name": "Mastercard",
            "description": "Mastercard bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "maestro"}},
        "data": {
            "name": "Maestro",
            "description": "Maestro bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": "nspkmir"}},
        "data": {
            "name": "НСПК Мир",
            "description": "НСПК Мир"
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank",
            "description": "Mocketbank",
            "terminal": {"value": [
                {"id": 1},
                {"id": 2},
                {"id": 3},
                {"id": 4},
                {"id": 5},
                {"id": 6}
            ]},
            "proxy": {
                "ref": {"id": 1},
                "additional": {}
            },
            "abs_account": "0000000001"
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 2},
        "data": {
            "name": "Tinkoff Credit Systems",
            "description": "Tinkoff Credit Systems",
            "terminal": {"value": [
                {"id": 7},
                {"id": 8}
            ]},
            "proxy": {
                "ref": {"id": 2},
                "additional": {}
            },
            "abs_account": "1000000001"
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 3},
        "data": {
            "name": "VTB24",
            "description": "VTB24",
            "terminal": {"value": [
                {"id": 9}
            ]},
            "proxy": {
                "ref": {"id": 3},
                "additional": {}
            },
            "abs_account": "1000000002"
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Visa Test",
            "description": "Mocketbank Visa Test",
            "payment_method": {"id": {"bank_card": "visa"}},
            "category": {"id": 1},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            },
            "payment_flow":
                {"hold": {"hold_lifetime": {"seconds": 3}}
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 2},
        "data": {
            "name": "Mocketbank MC Test",
            "description": "Mocketbank MC Test",
            "payment_method": {"id": {"bank_card": "mastercard"}},
            "category": {"id": 1},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 18, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            },
            "payment_flow":
                {"hold": {"hold_lifetime": {"seconds": 3}}
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 3},
        "data": {
            "name": "Mocketbank Maestro Test",
            "description": "Mocketbank Maestro Test",
            "payment_method": {"id": {"bank_card": "maestro"}},
            "category": {"id": 1},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 19, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},


    {"insert": {"object": {"terminal": {
        "ref": {"id": 4},
        "data": {
            "name": "Mocketbank Visa Live",
            "description": "Mocketbank Visa Live",
            "payment_method": {"id": {"bank_card": "visa"}},
            "category": {"id": 2},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 5},
        "data": {
            "name": "Mocketbank MC Live",
            "description": "Mocketbank MC Live",
            "payment_method": {"id": {"bank_card": "mastercard"}},
            "category": {"id": 2},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 18, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 6},
        "data": {
            "name": "Mocketbank Maestro Live",
            "description": "Mocketbank Maestro Live",
            "payment_method": {"id": {"bank_card": "maestro"}},
            "category": {"id": 2},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 19, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 7},
        "data": {
            "name": "TCS Visa",
            "description": "TCS Visa",
            "payment_method": {"id": {"bank_card": "visa"}},
            "category": {"id": 2},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 14, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 8},
        "data": {
            "name": "TCS MC",
            "description": "TCS MC",
            "payment_method": {"id": {"bank_card": "mastercard"}},
            "category": {"id": 2},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 17, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 9},
        "data": {
            "name": "VTB24 НСПК Мир",
            "description": "VTB24 НСПК Мир",
            "payment_method": {"id": {"bank_card": "nspkmir"}},
            "category": {"id": 2},
            "risk_coverage": "high",
            "cash_flow": [
                {
                    "source": {"provider": "settlement"},
                    "destination": {"merchant": "settlement"},
                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "payment_amount"}}
                },
                {
                    "source": {"system": "settlement"},
                    "destination": {"provider": "settlement"},
                    "volume": {"share": {"parts": {"p": 23, "q": 1000}, "of": "payment_amount"}}
                }
            ],
            "account": {
                "currency": {"symbolic_code": "RUB"},
                "settlement": $(${CURDIR}/create-account.sh RUB $*)
            }
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Proxy",
            "description": "Mocked bank proxy for integration test purposes",
            "url": "http://${PROXY_MOCKETBANK}:${THRIFT_PORT}/proxy/mocketbank",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 2},
        "data": {
            "name": "TCS Bank Proxy",
            "description": "TCS Bank Proxy",
            "url": "http://${PROXY_TINKOFF}:${THRIFT_PORT}/proxy/tinkoff",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 3},
        "data": {
            "name": "VTB24 Bank Proxy",
            "description": "VTB24 Bank Proxy",
            "url": "http://${PROXY_VTB}:${THRIFT_PORT}/proxy/vtb",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 100},
        "data": {
            "name": "Mocket Inspector Proxy",
            "description": "Mocked inspector proxy for integration test purposes",
            "url": "http://${PROXY_MOCKET_INSPECTOR}:${THRIFT_PORT}/proxy/mocket/inspector",
            "options": {"risk_score": "high"}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 1000},
        "data": {
            "name": "PIMP",
            "description": "Common Merchant Proxy",
            "url": "http://${PROXY_PIMP}:${THRIFT_PORT}/hg",
            "options": {}
        }
    }}}}

]}
