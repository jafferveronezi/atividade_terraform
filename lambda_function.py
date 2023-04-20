def lambda_metodo(event, context):
    print(context)
    print(event)
    print("Sou uma função lambda que subi com o terraform! vamo simbora!");
    # message = 'Sou uma função lambda que subi com o terraform! vamo simbora! Quem me chamou foi: {} {}!'.format(event['nome'], event['sobrenome'])  
    # return { 
    #     'message' : message
    # }
