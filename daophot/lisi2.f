	SUBROUTINE LISI2(RMT,VN,NEQ,ND)  
C                                       
C	RMT = MATRICE COEFFICIENTI     
C	VN  = VETTORE TERMINI NOTI IN INPUT 
C 	      VETTORE SOLUZIONE IN OUTPUT  
C	NEQ = NUMERO EQUAZIONI SISTEMA    
C	ND  = DIMENSIONI DELLA MATRICE RMT 
C                                         
	DIMENSION RMT(ND,ND),VN(1)       
	DO I=1,NEQ 
	A=RMT(I,I)
	DO L=I,NEQ 
	RMT(I,L)=RMT(I,L)/A    
	END DO                
	VN(I)=VN(I)/A        
	DO J=1,NEQ          
	IF(J.NE.I) THEN    
	B=RMT(J,I)        
	DO K=I,NEQ       
	RMT(J,K)=RMT(J,K)-RMT(I,K)*B 
	END DO                      
	VN(J)=VN(J)-VN(I)*B        
	END IF                    
	END DO                   
	END DO                  
	RETURN                 
	END
