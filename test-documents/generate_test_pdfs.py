"""
Generate realistic test PDF documents for credit application testing
"""
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT
from datetime import datetime, timedelta
import random

def create_pay_slip(filename, month, employee_name="Ahmed Benali", base_salary=12000):
    """Create a realistic Moroccan pay slip"""
    doc = SimpleDocTemplate(filename, pagesize=A4)
    story = []
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=18,
        textColor=colors.HexColor('#1e3a8a'),
        spaceAfter=30,
        alignment=TA_CENTER
    )
    
    header_style = ParagraphStyle(
        'Header',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.HexColor('#1e3a8a'),
        spaceAfter=10
    )
    
    # Company Header
    story.append(Paragraph("SOCIETE GENERALE MAROC", title_style))
    story.append(Paragraph("Bulletin de Paie / Pay Slip", styles['Heading2']))
    story.append(Spacer(1, 0.3*inch))
    
    # Employee Info
    story.append(Paragraph(f"<b>Employé:</b> {employee_name}", header_style))
    story.append(Paragraph(f"<b>Matricule:</b> EMP{random.randint(1000, 9999)}", header_style))
    story.append(Paragraph(f"<b>Période:</b> {month}", header_style))
    story.append(Paragraph(f"<b>Date d'émission:</b> {datetime.now().strftime('%d/%m/%Y')}", header_style))
    story.append(Spacer(1, 0.3*inch))
    
    # Salary Details
    gross_salary = base_salary
    cnss = round(gross_salary * 0.0448, 2)  # CNSS employee contribution
    amo = round(gross_salary * 0.0226, 2)   # AMO contribution
    cimr = round(gross_salary * 0.03, 2)    # CIMR contribution
    ir = round(gross_salary * 0.15, 2) if gross_salary > 6000 else 0  # IR (simplified)
    
    total_deductions = cnss + amo + cimr + ir
    net_salary = gross_salary - total_deductions
    
    salary_data = [
        ['Désignation', 'Montant (MAD)'],
        ['Salaire de Base', f'{gross_salary:,.2f}'],
        ['Prime d\'Ancienneté', f'{random.randint(500, 1500):,.2f}'],
        ['Total Brut', f'{gross_salary:,.2f}'],
        ['', ''],
        ['DEDUCTIONS', ''],
        ['CNSS (4.48%)', f'-{cnss:,.2f}'],
        ['AMO (2.26%)', f'-{amo:,.2f}'],
        ['CIMR (3%)', f'-{cimr:,.2f}'],
        ['IR', f'-{ir:,.2f}'],
        ['Total Déductions', f'-{total_deductions:,.2f}'],
        ['', ''],
        ['NET À PAYER', f'{net_salary:,.2f}'],
    ]
    
    table = Table(salary_data, colWidths=[4*inch, 2*inch])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1e3a8a')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('ALIGN', (1, 0), (1, -1), 'RIGHT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, -1), (-1, -1), colors.HexColor('#e0e7ff')),
        ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, -1), (-1, -1), 14),
        ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ('ROWBACKGROUNDS', (0, 1), (-1, -2), [colors.white, colors.HexColor('#f8fafc')]),
    ]))
    
    story.append(table)
    story.append(Spacer(1, 0.5*inch))
    
    # Footer
    story.append(Paragraph(
        "<i>Ce document est confidentiel et destiné uniquement à l'usage du salarié mentionné ci-dessus.</i>",
        styles['Normal']
    ))
    
    doc.build(story)
    print(f"✅ Created: {filename}")

def create_tax_declaration(filename, year=2024, total_income=150000):
    """Create a realistic Moroccan tax declaration"""
    doc = SimpleDocTemplate(filename, pagesize=A4)
    story = []
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=18,
        textColor=colors.HexColor('#dc2626'),
        spaceAfter=30,
        alignment=TA_CENTER
    )
    
    # Header
    story.append(Paragraph("ROYAUME DU MAROC", title_style))
    story.append(Paragraph("Direction Générale des Impôts", styles['Heading2']))
    story.append(Paragraph(f"Déclaration Fiscale Annuelle {year}", styles['Heading2']))
    story.append(Spacer(1, 0.3*inch))
    
    # Taxpayer Info
    story.append(Paragraph("<b>Informations du Contribuable</b>", styles['Heading3']))
    story.append(Paragraph(f"Nom: BENALI Ahmed", styles['Normal']))
    story.append(Paragraph(f"N° CIN: AB{random.randint(100000, 999999)}", styles['Normal']))
    story.append(Paragraph(f"N° Fiscal: {random.randint(10000000, 99999999)}", styles['Normal']))
    story.append(Paragraph(f"Année Fiscale: {year}", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))
    
    # Income Details
    gross_income = total_income
    professional_expenses = round(gross_income * 0.20, 2)  # 20% abattement
    taxable_income = gross_income - professional_expenses
    
    # Progressive IR calculation (simplified)
    if taxable_income <= 30000:
        ir = 0
    elif taxable_income <= 50000:
        ir = round((taxable_income - 30000) * 0.10, 2)
    elif taxable_income <= 60000:
        ir = round(2000 + (taxable_income - 50000) * 0.20, 2)
    elif taxable_income <= 80000:
        ir = round(4000 + (taxable_income - 60000) * 0.30, 2)
    else:
        ir = round(10000 + (taxable_income - 80000) * 0.38, 2)
    
    tax_data = [
        ['Rubrique', 'Montant (MAD)'],
        ['Revenu Brut Global', f'{gross_income:,.2f}'],
        ['Frais Professionnels (20%)', f'-{professional_expenses:,.2f}'],
        ['Revenu Net Imposable', f'{taxable_income:,.2f}'],
        ['', ''],
        ['Impôt sur le Revenu (IR)', f'{ir:,.2f}'],
        ['Versements Anticipés', f'{round(ir * 0.8, 2):,.2f}'],
        ['Régularisation à Payer', f'{round(ir * 0.2, 2):,.2f}'],
    ]
    
    table = Table(tax_data, colWidths=[4*inch, 2*inch])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#dc2626')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('ALIGN', (1, 0), (1, -1), 'RIGHT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#fef2f2')]),
    ]))
    
    story.append(table)
    story.append(Spacer(1, 0.5*inch))
    
    # Signature
    story.append(Paragraph(f"<b>Date:</b> {datetime.now().strftime('%d/%m/%Y')}", styles['Normal']))
    story.append(Spacer(1, 0.2*inch))
    story.append(Paragraph("_______________________", styles['Normal']))
    story.append(Paragraph("Signature du Contribuable", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))
    
    # Footer
    story.append(Paragraph(
        "<i>Cette déclaration doit être déposée avant le 28 février de l'année suivante.</i>",
        ParagraphStyle('Italic', parent=styles['Normal'], fontSize=9, textColor=colors.grey)
    ))
    
    doc.build(story)
    print(f"✅ Created: {filename}")

def create_bank_statement(filename, account_holder="Ahmed Benali"):
    """Create a realistic bank statement"""
    doc = SimpleDocTemplate(filename, pagesize=A4)
    story = []
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=16,
        textColor=colors.HexColor('#059669'),
        spaceAfter=20,
        alignment=TA_CENTER
    )
    
    # Bank Header
    story.append(Paragraph("ATTIJARIWAFA BANK", title_style))
    story.append(Paragraph("Relevé de Compte / Account Statement", styles['Heading3']))
    story.append(Spacer(1, 0.2*inch))
    
    # Account Info
    story.append(Paragraph(f"<b>Titulaire:</b> {account_holder}", styles['Normal']))
    story.append(Paragraph(f"<b>N° Compte:</b> 011780{random.randint(100000, 999999)}201", styles['Normal']))
    story.append(Paragraph(f"<b>Période:</b> {(datetime.now() - timedelta(days=30)).strftime('%d/%m/%Y')} - {datetime.now().strftime('%d/%m/%Y')}", styles['Normal']))
    story.append(Spacer(1, 0.3*inch))
    
    # Transactions
    balance = 25000
    transactions = [
        ['Date', 'Libellé', 'Débit', 'Crédit', 'Solde'],
        [(datetime.now() - timedelta(days=25)).strftime('%d/%m/%Y'), 'Salaire', '', '12,000.00', '25,000.00'],
        [(datetime.now() - timedelta(days=20)).strftime('%d/%m/%Y'), 'Loyer', '4,500.00', '', '20,500.00'],
        [(datetime.now() - timedelta(days=18)).strftime('%d/%m/%Y'), 'Courses', '850.00', '', '19,650.00'],
        [(datetime.now() - timedelta(days=15)).strftime('%d/%m/%Y'), 'Facture Electricité', '420.00', '', '19,230.00'],
        [(datetime.now() - timedelta(days=10)).strftime('%d/%m/%Y'), 'Virement Reçu', '', '2,000.00', '21,230.00'],
        [(datetime.now() - timedelta(days=5)).strftime('%d/%m/%Y'), 'Retrait GAB', '1,000.00', '', '20,230.00'],
    ]
    
    table = Table(transactions, colWidths=[1.2*inch, 2.5*inch, 1.2*inch, 1.2*inch, 1.2*inch])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#059669')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
        ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f0fdf4')]),
        ('ALIGN', (2, 1), (2, -1), 'RIGHT'),
        ('ALIGN', (3, 1), (3, -1), 'RIGHT'),
        ('ALIGN', (4, 1), (4, -1), 'RIGHT'),
    ]))
    
    story.append(table)
    story.append(Spacer(1, 0.3*inch))
    story.append(Paragraph(f"<b>Solde Final:</b> 20,230.00 MAD", styles['Normal']))
    
    doc.build(story)
    print(f"✅ Created: {filename}")

if __name__ == "__main__":
    print("🔵 Generating test PDF documents...")
    
    # Create 3 months of pay slips
    months = ["Octobre 2024", "Novembre 2024", "Décembre 2024"]
    for i, month in enumerate(months):
        create_pay_slip(f"payslip_{i+1}_{month.split()[0].lower()}_2024.pdf", month, base_salary=12000)
    
    # Create tax declaration
    create_tax_declaration("tax_declaration_2024.pdf", year=2024, total_income=150000)
    
    # Create bank statement
    create_bank_statement("bank_statement_recent.pdf")
    
    print("\n✅ All test documents generated successfully!")
    print("\nGenerated files:")
    print("  - payslip_1_octobre_2024.pdf")
    print("  - payslip_2_novembre_2024.pdf")
    print("  - payslip_3_decembre_2024.pdf")
    print("  - tax_declaration_2024.pdf")
    print("  - bank_statement_recent.pdf")
