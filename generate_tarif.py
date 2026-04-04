from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor

OUTPUT = "C:/Users/ghost/Documents/visit-and-smile/grille-tarifaire-visitandsmile.pdf"

# Colors
BLACK = HexColor("#030306")
BLACK_CARD = HexColor("#0a0a10")
GOLD = HexColor("#d4a931")
GOLD_LIGHT = HexColor("#f0cc50")
GOLD_DIM = HexColor("#a07d1a")
WHITE = HexColor("#e8e8f0")
WHITE_DIM = HexColor("#b0b0c0")
GRAY_MID = HexColor("#3d3d50")
GREEN = HexColor("#00e676")
RED = HexColor("#ff4757")

W, H = A4
M = 45  # margin

def draw_bg(c):
    c.setFillColor(BLACK)
    c.rect(0, 0, W, H, fill=1, stroke=0)
    c.setStrokeColor(HexColor("#0d0d18"))
    c.setLineWidth(0.3)
    for x in range(0, int(W), 40):
        c.line(x, 0, x, H)
    for yy in range(0, int(H), 40):
        c.line(0, yy, W, yy)

def gold_line(c, y):
    c.setStrokeColor(GOLD_DIM)
    c.setLineWidth(0.5)
    c.line(M, y, W - M, y)

def card(c, x, y, w, h, fill=BLACK_CARD):
    c.setFillColor(fill)
    c.setStrokeColor(HexColor("#1a1a28"))
    c.setLineWidth(0.5)
    c.roundRect(x, y, w, h, 4, fill=1, stroke=1)
    c.setStrokeColor(GOLD_DIM)
    c.setLineWidth(1)
    b = 8
    for cx, cy, bw, bh in [(x,y+h,b,0-b),(x+w,y+h,0-b,0-b),(x,y,b,b),(x+w,y,0-b,b)]:
        c.line(cx, cy, cx+bw, cy)
        c.line(cx, cy, cx, cy+bh)

def gold_card(c, x, y, w, h):
    c.setFillColor(HexColor("#0f0e08"))
    c.setStrokeColor(GOLD)
    c.setLineWidth(1)
    c.roundRect(x, y, w, h, 4, fill=1, stroke=1)

pdf = canvas.Canvas(OUTPUT, pagesize=A4)
draw_bg(pdf)

# ===== HEADER (compact) =====
pdf.setStrokeColor(GOLD)
pdf.setLineWidth(2)
pdf.line(M, H - 30, W - M, H - 30)

pdf.setFillColor(GOLD)
pdf.setFont("Helvetica-Bold", 24)
pdf.drawCentredString(W/2, H - 62, "VISIT & SMILE")
pdf.setFillColor(GRAY_MID)
pdf.setFont("Helvetica", 9)
pdf.drawCentredString(W/2, H - 76, "D E A D P O O L   I A")

pdf.setFillColor(WHITE_DIM)
pdf.setFont("Helvetica", 11)
pdf.drawCentredString(W/2, H - 100, "Offre d'integration IA pour auto-entrepreneurs immobilier")

gold_line(pdf, H - 115)

# ===== SECTION 1: Votre solution =====
y = H - 140
pdf.setFillColor(GOLD)
pdf.setFont("Helvetica-Bold", 13)
pdf.drawString(M + 5, y, "VOTRE SOLUTION")
pdf.setFillColor(WHITE_DIM)
pdf.setFont("Helvetica", 8)
pdf.drawString(195, y + 1, "3 agents IA qui travaillent pour vous 24/7")

y -= 20

agents = [
    ("AGENT COMPTABLE", [
        "Suivi automatique du chiffre d'affaires et des ventes",
        "Calcul commissions, charges URSSAF et benefice net",
        "Rappels declarations fiscales et echeances comptables"
    ], "01"),
    ("AGENT RESEAUX SOCIAUX", [
        "Creation et publication automatique de contenu immobilier",
        "Multi-plateforme : Instagram, Facebook, LinkedIn, TikTok",
        "Planning intelligent et horaires optimaux de publication"
    ], "02"),
    ("AGENT PLANNING & RDV", [
        "Gestion automatique des rendez-vous via Google Calendar",
        "Relances intelligentes post-visite, leads froids, apres-vente",
        "Messages personnalises : anniversaires, fetes, occasions speciales"
    ], "03"),
]

ch = 58
for title, lines, num in agents:
    card(pdf, M, y - ch, W - 2*M, ch)
    pdf.setFillColor(GOLD)
    pdf.setFont("Helvetica-Bold", 10)
    pdf.drawString(M + 18, y - 18, title)
    pdf.setFillColor(WHITE_DIM)
    pdf.setFont("Helvetica", 8)
    for i, line in enumerate(lines):
        pdf.drawString(M + 18, y - 30 - i*11, line)
    pdf.setFillColor(GOLD_DIM)
    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawRightString(W - M - 18, y - 35, num)
    y -= ch + 6

y -= 10
gold_line(pdf, y)

# ===== SECTION 2: Nos formules =====
y -= 25
pdf.setFillColor(GOLD)
pdf.setFont("Helvetica-Bold", 13)
pdf.drawString(M + 5, y, "NOS FORMULES")

y -= 22

cw = (W - 2*M - 15) / 2
fh = 130

# Formule 1
card(pdf, M, y - fh, cw, fh)
pdf.setFillColor(GOLD)
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(M + 16, y - 22, "FORMULE LANCEMENT")
pdf.setFillColor(GOLD_LIGHT)
pdf.setFont("Helvetica-Bold", 24)
pdf.drawString(M + 16, y - 52, "3 500")
pdf.setFillColor(WHITE_DIM)
pdf.setFont("Helvetica", 9)
pdf.drawString(M + 95, y - 47, "EUR setup")
pdf.setFont("Helvetica", 9)
pdf.drawString(M + 16, y - 72, "+ 300 EUR / mois")
gold_line(pdf, y - 82)
pdf.setFont("Helvetica", 7.5)
pdf.setFillColor(GRAY_MID)
pdf.drawString(M + 16, y - 96, "Hebergement inclus")
pdf.drawString(M + 16, y - 108, "APIs & maintenance inclus")
pdf.drawString(M + 16, y - 120, "Support prioritaire")

# Formule 2
x2 = M + cw + 15
gold_card(pdf, x2, y - fh, cw, fh)
pdf.setFillColor(GOLD)
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(x2 + 16, y - 22, "FORMULE TOUT-EN-UN")
pdf.setFillColor(GREEN)
pdf.setFont("Helvetica-Bold", 7)
pdf.drawRightString(x2 + cw - 16, y - 16, "POPULAIRE")
pdf.setFillColor(GOLD_LIGHT)
pdf.setFont("Helvetica-Bold", 24)
pdf.drawString(x2 + 16, y - 52, "590")
pdf.setFillColor(WHITE_DIM)
pdf.setFont("Helvetica", 9)
pdf.drawString(x2 + 80, y - 47, "EUR / mois")
pdf.drawString(x2 + 16, y - 72, "0 EUR de setup")
gold_line(pdf, y - 82)
pdf.setFont("Helvetica", 7.5)
pdf.setFillColor(GRAY_MID)
pdf.drawString(x2 + 16, y - 96, "Tout inclus, sans surprise")
pdf.drawString(x2 + 16, y - 108, "Engagement 12 mois")
pdf.drawString(x2 + 16, y - 120, "Support prioritaire")

y -= fh + 15
gold_line(pdf, y)

# ===== SECTION 3: Comparatif =====
y -= 25
pdf.setFillColor(GOLD)
pdf.setFont("Helvetica-Bold", 13)
pdf.drawString(M + 5, y, "POURQUOI C'EST RENTABLE")

y -= 20

comp_h = 85

# Commercial junior
card(pdf, M, y - comp_h, cw, comp_h)
pdf.setFillColor(RED)
pdf.setFont("Helvetica-Bold", 9)
pdf.drawString(M + 16, y - 18, "UN COMMERCIAL JUNIOR")
pdf.setFillColor(WHITE)
pdf.setFont("Helvetica-Bold", 20)
pdf.drawString(M + 16, y - 42, "~1 800 EUR/mois")
pdf.setFillColor(GRAY_MID)
pdf.setFont("Helvetica", 7.5)
pdf.drawString(M + 16, y - 58, "Horaires limites  |  Conges  |  Formation")
pdf.drawString(M + 16, y - 70, "1 seul canal a la fois")

# AI Hub
gold_card(pdf, x2, y - comp_h, cw, comp_h)
pdf.setFillColor(GREEN)
pdf.setFont("Helvetica-Bold", 9)
pdf.drawString(x2 + 16, y - 18, "DEADPOOL IA")
pdf.setFillColor(GOLD_LIGHT)
pdf.setFont("Helvetica-Bold", 20)
pdf.drawString(x2 + 16, y - 42, "300-590 EUR/mois")
pdf.setFillColor(WHITE_DIM)
pdf.setFont("Helvetica", 7.5)
pdf.drawString(x2 + 16, y - 58, "24/7  |  3 agents simultanes  |  0 conge")
pdf.drawString(x2 + 16, y - 70, "Scalable et evolutif")

# ===== FOOTER =====
pdf.setStrokeColor(GOLD_DIM)
pdf.setLineWidth(0.5)
pdf.line(M, 45, W - M, 45)
pdf.setFillColor(GRAY_MID)
pdf.setFont("Helvetica", 7)
pdf.drawString(M + 5, 33, "Proposition valable 30 jours  |  TVA non incluse")
pdf.drawRightString(W - M - 5, 33, "Visit & Smile  |  Deadpool IA  |  contact@visitandsmile.fr")

pdf.setStrokeColor(GOLD)
pdf.setLineWidth(2)
pdf.line(M, 22, W - M, 22)

pdf.save()
print(f"PDF genere : {OUTPUT}")
