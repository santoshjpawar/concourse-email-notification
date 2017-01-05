package main

import (
	"log"
	"io/ioutil"
	"net/smtp"
	"fmt"
	"flag"
	"strings"
)

func main() {

	var emailId, password, smtpServer, smtpPort, recepient, subject, msgFile string
	flag.StringVar(&emailId, "emailId", "", "Email ID")
	flag.StringVar(&password, "password", "", "Email password")
	flag.StringVar(&smtpServer, "smtpServer", "smtp.gmail.com", "SMTP server name")
	flag.StringVar(&smtpPort, "smtpPort", "587", "SMTP server port")
	flag.StringVar(&recepient, "recepient", "", "Email recepient")
	flag.StringVar(&subject, "subject", "", "Email subject")
	flag.StringVar(&msgFile, "msgFile", "/tmp/body", "File path containing email body")
	flag.Parse()

	sArr := strings.Split(recepient, ", ")
	firstEmail := sArr[0]

	log.Println("EmailId: " + emailId)
	log.Println("SMTP Server: " + smtpServer)
	log.Println("SMTP Port: " + smtpPort)
	log.Println("Recepient: " + recepient)
	log.Println("First Email: " + firstEmail)
	log.Println("Subject: " + subject)
	log.Println("Message File: " + msgFile)

	// Read 'body'
	bs, err := ioutil.ReadFile(msgFile)
	if err != nil {
		log.Print("Failed to read 'body' file")
		return
	}
	body := string(bs)
	log.Print("Message body:", body)

	// Construct header
	header := make(map[string]string)
	header["From"] = emailId
	header["To"] = firstEmail
	header["Subject"] = subject
	header["MIME-Version"] = "1.0"
	header["Content-Type"] = "text/html; charset=\"utf-8\""

	// Construct message
	message := ""
	for k, v := range header {
		message += fmt.Sprintf("%s: %s\r\n", k, v)
	}
	message += "\r\n" + string([]byte(body))

	err = smtp.SendMail(smtpServer + ":" + smtpPort,
		smtp.PlainAuth("", emailId, password, "smtp.gmail.com"),
		emailId, sArr, []byte(message))

	if err != nil {
		log.Printf("SMTP error: %s", err)
		return
	}
	log.Print("Message sent successfully")
}