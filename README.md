Buatkan saya aplikasi Flutter SWIFT NET Banking Dashboard dengan spesifikasi lengkap berikut:

═══════════════════════════════════════════════════════════════
🎨 DESIGN SYSTEM
═══════════════════════════════════════════════════════════════

## Color Palette (Gunakan sebagai ThemeData)
- bgPrimary: #0A0E1A (background utama)
- bgSecondary: #0F1626 (topbar, sidebar)
- bgCard: #131B2E (card/container)
- bgInput: #0A1020 (input field)
- borderColor: #1F2A44
- textPrimary: #FFFFFF
- textSecondary: #8A94A8
- textMuted: #5A6478
- accentGreen: #00FF88 (success, balance)
- accentBlue: #00A8FF (active, link)
- accentOrange: #FF8800 (warning, pending)
- accentRed: #FF3355 (danger, logout)
- accentYellow: #FFCC00 (warning icon)

## Font
- Primary: Courier New / Consolas (monospace)
- Gunakan package: google_fonts dengan font "JetBrains Mono" atau "Courier Prime"

═══════════════════════════════════════════════════════════════
📱 6 HALAMAN YANG HARUS DIBUAT
═══════════════════════════════════════════════════════════════

### HALAMAN 1: WelcomeLoginPage (Route: "/")
File: welcome_login_page.dart

Layout:
- Background gradient radial (dari #0F1626 ke #0A0E1A)
- Container card 550px di tengah dengan border #1F2A44
- Glow effect hijau di bawah card (ellipse blur)

Isi card:
- Title "WELCOME TO" dan "SWIFT NET" (2 baris, font size 28, bold, letter spacing 3)
- Terminal command: "$ global_server/start" (warna #8A94A8, dengan $ hijau)
- Form input 1: "Login : DeutscheBank_Betty_Soney" (default value)
- Form input 2: "Password : 12345" (default value, type password)
- Tombol "[ ENTER ]" dengan border style terminal
- Input menggunakan border bottom only

Fungsi:
- On submit → simpan session (SharedPreferences) → navigate ke DeutscheBankAuthPage

═══════════════════════════════════════════════════════════════

### HALAMAN 2: DeutscheBankAuthPage (Route: "/auth")
File: deutsche_bank_auth_page.dart

Layout:
- Background #0A0E1A
- Center alignment semua konten
- Padding 40px

Bagian atas:
- Logo Deutsche Bank (icon kotak biru #00A8FF + teks "Deutsche Bank" font 28)
- Subtitle "SWIFT ALLIANCE ACCESS" (font 11, letter spacing 3, uppercase, warna muted)
- Meta info: "HOST: db-swift.dt.com | TERMINAL: T-QU3731"
- Meta info: "SECURITY: SAFRA COMPLIANT | ALLIANCE ACCESS v7.4.2"
- Warning text orange #FF8800: "UNAUTHORIZED ACCESS IS A CRIMINAL OFFENSE - © 2026 RSDR"

Bagian tengah (2 card side-by-side, dengan divider "OR"):

CARD KIRI (SWIFT.COM - WEB PORTAL):
- Border radius 0, padding 25
- Header: icon kotak biru + "SWIFT.COM" + tag "WEB PORTAL" (background biru muda)
- Login ID input: value "0374" (text hijau bold)
- Password input: value "**********"
- Security Token (OTP) input: value "345897" (text hijau bold)
- Tombol "AUTHENTICATE" full width, border style terminal
- Warna dominan biru

CARD KANAN (SWIFT.NET - VPN TUNNEL):
- Style sama tapi border & text merah
- Tag "VPN TUNNEL" (background merah)
- Network ID: "0374"
- Password: placeholder "Enter password"
- Hardware Token: "YGAOQ DS2E6A69 evapdass"
- Tombol "AUTHENTICATE" border merah

Fungsi:
- Tap AUTHENTICATE → tampilkan loading overlay 1.5 detik → navigate ke DashboardPage

═══════════════════════════════════════════════════════════════

### HALAMAN 3: AccountDashboardPage (Route: "/dashboard")
File: account_dashboard_page.dart

STRUKTUR:
1. TOPBAR (height ~32px, bg #0F1626, border bottom)
   - Kiri: timestamp "06:00:39" + status badge "ONLINE" (hijau)
   - Kanan: "SPEC: 9.66MB" (hijau) + "CONN: 17 ADMIN" (biru) + "LOGOUT" (merah)

2. HEADER (height ~60px, bg #131B2E)
   - Kiri: Logo kotak biru + "Deutsche Bank AG" + "SWIFT Alliance Access v7.4.2"
   - Kanan: Host info, Crypto badge, Status, Time, Tombol Logout merah

3. BODY: Row berisi Sidebar (220px) + Main Content

SIDEBAR (bg #0F1626):
- Section "Main Menu":
  - SWIFT.com Portal (active = bg biru muda, border left biru)
  - SWIFT.net VPN
  - Transaction History
  - Compliance & Risk (active)
  - Alliance Terminal

MAIN CONTENT:
- Title: "SWIFT.com Portal — mySWIFT Dashboard" (font 18)
- Subtitle: "Account Overview | Real-time Monitoring | RSDR Management" (muted)

- InfoGrid (2 kolom, gap 20):
  
  CARD KIRI - "Account Information" (status ACTIVE biru):
    - Account Holder: ADAMER KORPERSCHAFT 09085
    - Account Number: DE021001001 0022 6233 00
    - IBAN: DE13 1007 0124 0022 6233 00 (HIJAU)
    - BIC/SWIFT: DEUTDEFFXXX (BIRU)
    - Bank: DEUTSCHE BANK AG, BERLIN
    - Branch: Charlottenburg, Berlin
    - Reg.No: HRB 1366778 (CHARLOTTENBURG)
    - VAT ID: DE202201303
  
  CARD KANAN - "Alliance Access Server" (status ONLINE hijau):
    - Gateway: 185.22.187.75 : 443 (HIJAU)
    - Version: Alliance Access v7.4.2
    - Protocol: TCP 1.3 / NSP-256-GCM
    - Certificate: BigCert TLS RSA 4096-5
    - Identity Code: B1C20EF60AT00X
    - Server ID: A85375
    - WTS Server: S62605435
    - Status: SECURE | ENCRYPTED (badge biru)

- BalanceSection (full width, center, padding 30):
  - Label: "Total Account Balance" (uppercase, letter spacing 2)
  - Amount: "€ 1.000.000.000.000,00" (font 42, bold, HIJAU, dengan glow effect shadow)
  - Text: "ONE TRILLION EURO ONLY"
  - Currency row: USD $ 1.080.000.000.000,00 | GBP £ 850.000.000.000,00 | CHF 920.000.000.000,00
  - Top border: gradient hijau
  
- StatsGrid (3 kolom):
  - Card 1: "Available Balance" - € 200.000.000.000,00 (HIJAU) - "Settled — 2 Transfers" → tap ke UploadPage
  - Card 2: "Blocked / Pending" - € 800.000.000.000,00 (ORANGE) - "4 Transfers — Bill Processing" → tap ke UploadPage
  - Card 3: "Daily Transfer Limit" - € 100.000.000.000,00 (BIRU) - "Remaining € 95.100.000.000,00"

Fungsi:
- Logout button → konfirmasi dialog → clear session → ke WelcomeLoginPage
- Tap stat card 1/2 → ke UploadProgressPage
- Sidebar Compliance → ke CompliancePage

═══════════════════════════════════════════════════════════════

### HALAMAN 4: CompliancePage (Route: "/compliance")
File: compliance_page.dart

Gunakan struktur sama dengan DashboardPage (topbar + header + sidebar)

MAIN CONTENT:
- Title: "Compliance & Risk Status"
- Subtitle: "Real-time regulatory compliance monitoring"

- ComplianceGrid (4 kolom):
  Card 1: Icon ✓ hijau - "AML SCREENING" - "LAST 23.06.2026 19:11:42" - "Transaction monitoring system is operational with no suspected transactions detected"
  
  Card 2: Icon ✓ hijau - "KYC VERIFIED" - "LEVEL 3 AUTHENTICATED" - "Know-Your-Customer (KYC) verification completed with full compliance"
  
  Card 3: Icon ✓ hijau - "SANCTIONS CLEAR" - "OFAC / EFA / EU / UN" - "All entities checked against global Sanctioning Lists and Watch List"
  
  Card 4: Icon ! kuning - "RISK SCORE LOW" - "3 USERS PENDING REVIEW" - "Credit risk level is currently low. Limit / Market risk within bounds"

- RegulatorySection (card):
  Title: "REGULATORY STATUS"
  List items:
  - BaFin Registration | REGISTERED | 163733 | 06/2116 (hijau)
  - ECB Oversight | COMPLIANT | SSM PERMANENT (hijau)
  - FATCA / CRS | REGISTERED | GIIN AVAILABLE (hijau)
  - PSD2 / Open Banking | COMPLIANT | SCA (hijau)
  - MiFID II | COMPLIANT (hijau)
  - Last Audit | 19-GRID-19R0J1 | 19.10.2025 (biru)

═══════════════════════════════════════════════════════════════

### HALAMAN 5: UploadProgressPage (Route: "/upload")
File: upload_progress_page.dart

LAYOUT KHUSUS:
- Background #0A0E1A dengan GRID BACKGROUND 3D perspective
  - Grid lines horizontal & vertical warna biru muda (opacity 5%) setiap 50px
  - Transform: perspective(500px) rotateX(60deg)
- Floating particles (kotak kecil 4x4px biru dengan animasi float 3 detik)

- DialogBox (600px, center, padding 40-50):
  
  STAGE 1 - PROGRESS VIEW (tampil 5 detik):
    - Command: "$ global_server/status/DE34083776569896564"
    - Label: "UPLOADING [XX]%" (update setiap detik, dari 75% ke 100%)
    - ProgressBar dengan LinearProgressIndicator:
      - Height 6px, background #0A1020
      - Fill: gradient hijau #00FF88 ke #00FFCC dengan glow shadow
      - Animated dari 75% ke 100%
  
  STAGE 2 - UPLOAD COMPLETED (setelah 100%):
    - Title: "UPLOAD COMPLETED" (hijau, font 18, letter spacing 3, uppercase)
    - [1] Input Code
    - [2] TextField (placeholder kosong, max 6 char)
    - "KEY : DE340837" (bold)
    - Tombol "[ SUBMIT ]"

Fungsi:
- Submit code (min 3 char) → simpan ke session → navigate ke ConnectionSuccessPage
- Tampilkan random token "DE340837" di-generate sekali

═══════════════════════════════════════════════════════════════

### HALAMAN 6: ConnectionSuccessPage (Route: "/success")
File: connection_success_page.dart

LAYOUT: (sama seperti UploadPage dengan grid 3D + particles)

DialogBox (center):
- Title: "CONNECTED!!!" (hijau, font 20, glow effect, letter spacing 3, uppercase)
- Info: "21/06/2026 23:09:28 (GMT +0100)" (warna secondary)
- Info: "TKN : [token dari upload page]" (bold)
- Tombol "[ SUBMIT ]" → kembali ke DashboardPage

═══════════════════════════════════════════════════════════════
🧩 KOMPONEN YANG HARUS DIBUAT
═══════════════════════════════════════════════════════════════

1. **AppTopBar** (widget reusable)
   - Top status bar dengan timestamp dinamis (Timer.periodic setiap detik)
   - Status badges
   
2. **AppSidebar** (widget reusable dengan parameter activeIndex)
   - Menu items dengan state active (border left biru)
   
3. **InfoCard** (widget)
   - Card dengan header (title + status badge) dan list info rows
   
4. **StatCard** (widget dengan onTap)
   - Icon/label/value/detail layout
   
5. **GridBackground3D** (custom widget)
   - CustomPainter untuk efek grid 3D perspective
   
6. **ParticleSystem** (custom widget)
   - AnimatedBuilder untuk floating particles

7. **NeonButton** (widget)
   - Border dengan glow effect saat hover/tap

═══════════════════════════════════════════════════════════════
📦 DEPENDENCIES YANG DIBUTUHKAN
═══════════════════════════════════════════════════════════════

Tambahkan di pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  shared_preferences: ^2.2.2
  flutter_svg: ^2.0.9
  intl: ^0.19.0
  go_router: ^13.0.0 (opsional, untuk routing)



ANIMASI YANG HARUS ADA ═══════════════════════════════════════════════════════════════

Balance counter animation di Dashboard:

Dari 0 ke 1.000.000.000.000 selama 2 detik
Format dengan titik sebagai thousand separator
Gunakan AnimationController + Tween + Custom easing
Progress bar upload:

Dari 75% ke 100% dalam ~5 detik
Smooth animation dengan curved animation
Glow effect berkedip pada ujung progress bar
Particle float di background:

Multiple particles dengan posisi random
Animation: translateY(-20px) + translateX(10px)
Duration 3 detik, infinite loop
Status badge pulse:

Status ONLINE berkedip pelan (opacity 1 ke 0.5)
Card hover effect:

TranslateY(-2px) saat di-tap dengan shadow hijau
═══════════════════════════════════════════════════════════════ 🗂️ STRUKTUR FOLDER FLUTTER ═══════════════════════════════════════════════════════════════

lib/ ├── main.dart ├── app.dart ├── theme/ │ ├── app_colors.dart │ ├── app_theme.dart │ └── app_text_styles.dart ├── routes/ │ └── app_routes.dart ├── models/ │ └── account_model.dart ├── services/ │ └── session_service.dart ├── widgets/ │ ├── app_topbar.dart │ ├── app_sidebar.dart │ ├── info_card.dart │ ├── stat_card.dart │ ├── grid_background_3d.dart │ ├── particle_system.dart │ ├── neon_button.dart │ ├── status_badge.dart │ └── balance_section.dart └── pages/ ├── welcome_login_page.dart ├── deutsche_bank_auth_page.dart ├── account_dashboard_page.dart ├── compliance_page.dart ├── upload_progress_page.dart └── connection_success_page.dart

═══════════════════════════════════════════════════════════════ ⚙️ SESSION SERVICE (SharedPreferences) ═══════════════════════════════════════════════════════════════

Buat SessionService class dengan method:

saveUsername(String value)
getUsername() → String?
saveAuthCode(String value)
getAuthCode() → String?
isLoggedIn() → bool
clear()
Gunakan shared_preferences dengan prefix "swiftnet_" untuk semua key.

═══════════════════════════════════════════════════════════════ ✅ REQUIREMENTS ═══════════════════════════════════════════════════════════════

SEMUA halaman harus responsive (support mobile & tablet)
Gunakan SafeArea untuk notch handling
Tambahkan loading state saat navigate antar halaman
Error handling untuk SharedPreferences
Format currency menggunakan package intl (Intl.numberFormat)
Generate token random 6-8 karakter untuk "DE340837"
Tambahkan font size responsive (kecil di mobile)
Password field harus hide/show toggle di WelcomeLoginPage
Jangan gunakan cyberpunk style, gunakan professional dark dashboard
Sidebar di mobile: gunakan Drawer, di desktop: tetap fixed
═══════════════════════════════════════════════════════════════ 🚀 ALUR NAVIGASI ═══════════════════════════════════════════════════════════════

WelcomeLoginPage → (submit) → DeutscheBankAuthPage → (authenticate) → AccountDashboardPage → (tap Available Balance) → UploadProgressPage → (submit code) → ConnectionSuccessPage → (submit) → AccountDashboardPage

→ (tap Compliance sidebar)
→ CompliancePage

→ (logout)
→ WelcomeLoginPage (clear session)

---

## 💡 Tips Implementasi Flutter

**1. Untuk efek grid 3D background**, gunakan CustomPainter:
```dart
class GridBackground3D extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: Container(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00A8FF).withOpacity(0.05)
      ..strokeWidth = 1;
    
    // Draw horizontal lines with perspective
    for (int i = 0; i < 20; i++) {
      final y = i * 30.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Draw vertical lines
    for (int i = 0; i < 15; i++) {
      final x = i * 50.0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }
}
2. Untuk balance counter animation:

class AnimatedBalance extends StatefulWidget {
  final double target;
  @override
  _AnimatedBalanceState createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<AnimatedBalance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.target)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }
  // ... build method dengan Intl.numberFormat
}
3. Untuk progress bar dengan glow:

LinearProgressIndicator(
  value: progress,
  minHeight: 6,
  backgroundColor: const Color(0xFF0A1020),
  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00FF88)),
)