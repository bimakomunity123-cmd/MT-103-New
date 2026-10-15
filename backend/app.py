from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import random
import string

app = Flask(__name__)
CORS(app)

# ============ DATA (bisa lo ganti sesuai kebutuhan) ============
USERS_DB = {
    "DeutscheBank_Betty_Bima": {
        "password": "12345",
        "account_holder": "ADAMER KORPERSCHAFT 09085",
        "account_number": "DE021001001 0022 6233 00",
        "iban": "DE13 1007 0124 0022 6233 00",
        "bic": "DEUTDEFFXXX",
        "bank": "DEUTSCHE BANK AG, BERLIN",
        "branch": "Charlottenburg, Berlin",
        "reg_no": "HRB 1366778 (CHARLOTTENBURG)",
        "vat_id": "DE202201303",
        "balance_eur": 1000000000000,
        "available_eur": 200000000000,
        "blocked_eur": 800000000000,
        "daily_limit_eur": 100000000000
    },
    "Bima": {
        "password": "12345",
        "account_holder": "ADAMER KORPERSCHAFT 09085",
        "account_number": "DE021001001 0022 6233 00",
        "iban": "DE13 1007 0124 0022 6233 00",
        "bic": "DEUTDEFFXXX",
        "bank": "DEUTSCHE BANK AG, BERLIN",
        "branch": "Charlottenburg, Berlin",
        "reg_no": "HRB 1366778 (CHARLOTTENBURG)",
        "vat_id": "DE202201303",
        "balance_eur": 1000000000000,
        "available_eur": 200000000000,
        "blocked_eur": 800000000000,
        "daily_limit_eur": 100000000000
    },
    "DeutscheBank_Betty_Soney": {
        "password": "12345",
        "account_holder": "ADAMER KORPERSCHAFT 09085",
        "account_number": "DE021001001 0022 6233 00",
        "iban": "DE13 1007 0124 0022 6233 00",
        "bic": "DEUTDEFFXXX",
        "bank": "DEUTSCHE BANK AG, BERLIN",
        "branch": "Charlottenburg, Berlin",
        "reg_no": "HRB 1366778 (CHARLOTTENBURG)",
        "vat_id": "DE202201303",
        "balance_eur": 1000000000000,
        "available_eur": 200000000000,
        "blocked_eur": 800000000000,
        "daily_limit_eur": 100000000000
    }
}

# ============ HELPER ============
def gen_token(length=8):
    chars = string.ascii_uppercase + string.digits
    return 'DE' + ''.join(random.choice(chars) for _ in range(length))

# ============ ROUTES ============
@app.route('/')
def home():
    return jsonify({"service": "SWIFT NET API", "version": "v7.4.2", "status": "online"})

@app.route('/api/health')
def health():
    return jsonify({"status": "online", "timestamp": datetime.now().isoformat()})

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json or {}
    username = data.get('username')
    password = data.get('password')
    if username in USERS_DB and USERS_DB[username]['password'] == password:
        return jsonify({"success": True, "message": "OK", "user": {"username": username}})
    return jsonify({"success": False, "message": "Invalid"}), 401

@app.route('/api/auth/validate', methods=['POST'])
def validate():
    return jsonify({"success": True, "auth_id": "DE340837", "timestamp": datetime.now().isoformat()})

@app.route('/api/account/info', methods=['GET'])
def account_info():
    username = request.args.get('username', 'DeutscheBank_Betty_Bima')
    user = USERS_DB.get(username, USERS_DB.get('DeutscheBank_Betty_Bima', USERS_DB.get('DeutscheBank_Betty_Soney')))
    return jsonify({"success": True, "data": user})

@app.route('/api/account/balance', methods=['GET'])
def balance():
    return jsonify({
        "success": True,
        "total": 1000000000000,
        "available": 200000000000,
        "blocked": 800000000000,
        "currency": "EUR"
    })

@app.route('/api/compliance/status', methods=['GET'])
def compliance():
    return jsonify({
        "success": True,
        "data": {
            "aml": "active",
            "kyc": "verified",
            "sanctions": "clear",
            "risk_score": "low"
        }
    })

@app.route('/api/transactions', methods=['GET'])
def transactions():
    return jsonify({
        "success": True,
        "data": [
            {"date": "2026-06-21", "amount": 50000000000, "type": "OUTGOING"},
            {"date": "2026-06-20", "amount": 120000000000, "type": "INCOMING"},
            {"date": "2026-06-19", "amount": 75500000000, "type": "OUTGOING"}
        ]
    })

@app.route('/api/upload/start', methods=['POST'])
def upload_start():
    return jsonify({
        "success": True,
        "upload_id": gen_token(10),
        "status": "in_progress",
        "started_at": datetime.now().isoformat()
    })

@app.route('/api/upload/status', methods=['GET'])
def upload_status():
    return jsonify({
        "success": True,
        "progress": random.randint(70, 95),
        "status": "uploading",
        "upload_id": "DE340837765"
    })

@app.route('/api/upload/complete', methods=['POST'])
def upload_complete():
    data = request.json or {}
    code = data.get('code')
    return jsonify({
        "success": True,
        "message": "Upload completed",
        "token": "DE340837",
        "verified": code is not None and len(code) >= 3
    })

@app.route('/api/transfer', methods=['POST'])
def transfer():
    data = request.json or {}
    return jsonify({
        "success": True,
        "transaction_id": gen_token(10),
        "amount": data.get('amount', 0),
        "status": "processing",
        "estimated_completion": "2026-06-23T20:00:00"
    })

if __name__ == '__main__':
    print("=" * 50)
    print("SWIFT NET Backend: http://localhost:5000")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=True)
